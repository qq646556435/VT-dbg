#include "Driver.h"
#include "poolmanager.h"
#include "Globals.h"
#include "vmcall_handler.h"
#include "interrupt.h"
#include "vmcall_reason.h"
#include "vmcall_token.h"
#include "invalid_ept.h"
#include "msr.h"
#include "mtrr.h"
#include "EPT.h"
#include "AsmCallset.h"
#include "hypervisor_routines.h"
#include "vmexit_handler.h"
#include "vmcs.h"

void restore_segment_registers()
{
	__writemsr(IA32_FS_BASE, hv::vmread(GUEST_FS_BASE));
	__writemsr(IA32_GS_BASE, hv::vmread(GUEST_GS_BASE));
	__reload_gdtr(hv::vmread(GUEST_GDTR_BASE), hv::vmread(GUEST_GDTR_LIMIT));
	__reload_idtr(hv::vmread(GUEST_IDTR_BASE), hv::vmread(GUEST_IDTR_LIMIT));
}

void call_vmxoff(__vcpu* vcpu)
{
	//vcpu->vmx_off_state.guest_rip = vcpu->vmexit_info.guest_rip + vcpu->vmexit_info.instruction_length;
	//vcpu->vmx_off_state.guest_rsp = vcpu->vmexit_info.guest_registers->rsp;
	vcpu->vmx_off_state.vmx_off_executed = true;
}

using vmcall_handler_fn = bool(*)(
	__vcpu* vcpu,
	unsigned __int64 p1,
	unsigned __int64 p2,
	unsigned __int64 p3,
	unsigned __int64 p4,
	unsigned __int64 p5,
	unsigned __int64 p6,
	unsigned __int64 p7);

struct vmcall_entry_t
{
	unsigned __int64 enc;
	vmcall_handler_fn fn;
};

static bool vmh_test(__vcpu* const v, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	adjust_rip(v);
	return true;
}

static bool vmh_vmxoff(__vcpu* const v, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	call_vmxoff(v);
	adjust_rip(v);
	return true;
}

static bool vmh_ept_cc_hook(__vcpu* const v, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	adjust_rip(v);
	return true;
}

static bool vmh_ept_int1_hook(__vcpu* const v, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	adjust_rip(v);
	return true;
}

static bool vmh_ept_rip_hook(__vcpu* const v, unsigned __int64 const p1, unsigned __int64 const p2, unsigned __int64 const p3, unsigned __int64 const p4, unsigned __int64, unsigned __int64, unsigned __int64)
{
	bool const st = ept::vmcall_hook_function(*v->ept_state, (void*)p1, (void*)p2, (void**)p3, p4);
	adjust_rip(v);
	return st;
}

static bool vmh_ept_hook_function(__vcpu* const v, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	adjust_rip(v);
	return true;
}

static bool vmh_ept_unhook(__vcpu* const v, unsigned __int64 const p1, unsigned __int64 const p2, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	bool st = true;
	if (p1 == true)
		ept::unhook_all_functions(*v->ept_state);
	else
		st = ept::unhook_function(*v->ept_state, p2);
	adjust_rip(v);
	return st;
}

static bool vmh_invept(__vcpu* const v, unsigned __int64 const p1, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	if (p1 == true)
	{
		_mm_mfence();
		invept_all_contexts_func();
	}
	else
	{
		_mm_mfence();
		invept_single_context_func((*v->ept_state).ept_pointer->all);
	}
	adjust_rip(v);
	return true;
}

static bool vmh_dump_pool(__vcpu* const v, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	pool_manager::dump_pools_info();
	adjust_rip(v);
	return true;
}

static bool vmh_dump_vmcs(__vcpu* const v, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	hv::dump_vmcs();
	adjust_rip(v);
	return true;
}

static bool vmh_hide_hv(__vcpu* const v, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	g_vmm_context.hv_presence = false;
	adjust_rip(v);
	return true;
}

static bool vmh_unhide_hv(__vcpu* const v, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	g_vmm_context.hv_presence = true;
	adjust_rip(v);
	return true;
}

static bool vmh_hide_software_breakpoint(__vcpu* const v, unsigned __int64 const p1, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	bool const st = ept::set_hide_software_breakpoint((PVT_BREAK_POINT)p1);
	adjust_rip(v);
	return st;
}

static bool vmh_read_software_breakpoint(__vcpu* const v, unsigned __int64 const p1, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	bool const st = ept::get_hide_software_breakpoint(*v->ept_state, (PVT_BREAK_POINT)p1);
	adjust_rip(v);
	return st;
}

static bool vmh_read_ept_fake_page(__vcpu* const v, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	adjust_rip(v);
	return true;
}

static bool vmh_watch_writes(__vcpu* const v, unsigned __int64 const p1, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	bool const st = SetBreakpoint((PVT_BREAK_POINT)p1, EPTW_WRITE);
	adjust_rip(v);
	return st;
}

static bool vmh_watch_reads(__vcpu* const v, unsigned __int64 const p1, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	bool const st = SetBreakpoint((PVT_BREAK_POINT)p1, EPTW_READWRITE);
	adjust_rip(v);
	return st;
}

static bool vmh_watch_executes(__vcpu* const v, unsigned __int64 const p1, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	bool const st = SetBreakpoint((PVT_BREAK_POINT)p1, EPTW_EXECUTE);
	adjust_rip(v);
	return st;
}

static bool vmh_watch_delete(__vcpu* const v, unsigned __int64 const p1, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	bool const st = RemoveBreakpoint((PVT_BREAK_POINT)p1);
	adjust_rip(v);
	return st;
}

static bool vmh_get_breakpoint(__vcpu* const v, unsigned __int64 const p1, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	bool const st = hv::get_breakpoint_detected(v, (PBREAKPOINT_DETECTED)p1);
	adjust_rip(v);
	return st;
}

static bool vmh_init_offset(__vcpu* const v, unsigned __int64 const p1, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64, unsigned __int64)
{
	bool const st = InitOffset((PWINDOWS_STRUCT)p1);
	adjust_rip(v);
	return st;
}

// Shuffled order; enc = vmcall_reason_encode(enum) - no contiguous switch/jump table.
static vmcall_entry_t const g_vmcall_entries[] = {
	{ vmcall_reason_encode(VMCALL_GET_BREAKPOINT), vmh_get_breakpoint },
	{ vmcall_reason_encode(VMCALL_EPT_RIP_HOOK), vmh_ept_rip_hook },
	{ vmcall_reason_encode(VMCALL_VMXOFF), vmh_vmxoff },
	{ vmcall_reason_encode(VMCALL_TEST), vmh_test },
	{ vmcall_reason_encode(VMCALL_WATCH_WRITES), vmh_watch_writes },
	{ vmcall_reason_encode(VMCALL_INIT_OFFSET), vmh_init_offset },
	{ vmcall_reason_encode(VMCALL_INVEPT_CONTEXT), vmh_invept },
	{ vmcall_reason_encode(VMCALL_HIDE_SOFTWARE_BREAKPOINT), vmh_hide_software_breakpoint },
	{ vmcall_reason_encode(VMCALL_DUMP_VMCS_STATE), vmh_dump_vmcs },
	{ vmcall_reason_encode(VMCALL_EPT_CC_HOOK), vmh_ept_cc_hook },
	{ vmcall_reason_encode(VMCALL_READ_SOFTWARE_BREAKPOINT), vmh_read_software_breakpoint },
	{ vmcall_reason_encode(VMCALL_EPT_INT1_HOOK), vmh_ept_int1_hook },
	{ vmcall_reason_encode(VMCALL_WATCH_DELETE), vmh_watch_delete },
	{ vmcall_reason_encode(VMCALL_EPT_UNHOOK_FUNCTION), vmh_ept_unhook },
	{ vmcall_reason_encode(VMCALL_DUMP_POOL_MANAGER), vmh_dump_pool },
	{ vmcall_reason_encode(VMCALL_WATCH_READS), vmh_watch_reads },
	{ vmcall_reason_encode(VMCALL_HIDE_HV_PRESENCE), vmh_hide_hv },
	{ vmcall_reason_encode(VMCALL_READ_EPT_FAKE_PAGE_MEMORY), vmh_read_ept_fake_page },
	{ vmcall_reason_encode(VMCALL_WATCH_EXECUTES), vmh_watch_executes },
	{ vmcall_reason_encode(VMCALL_UNHIDE_HV_PRESENCE), vmh_unhide_hv },
	{ vmcall_reason_encode(VMCALL_EPT_HOOK_FUNCTION), vmh_ept_hook_function },
};

void vmexit_vmcall_handler(__vcpu* vcpu)
{
	bool status = true;
	unsigned __int64 vmcall_parameter1 = 0;
	unsigned __int64 vmcall_parameter2 = 0;
	unsigned __int64 vmcall_parameter3 = 0;
	unsigned __int64 vmcall_parameter4 = 0;
	unsigned __int64 vmcall_parameter5 = 0;
	unsigned __int64 vmcall_parameter6 = 0;
	unsigned __int64 vmcall_parameter7 = 0;

	guest_context* const gpr = vcpu->vmexit_info.guest_registers;
	unsigned __int64 const guest_cr3 = hv::vmread(GUEST_CR3);
	unsigned __int64 const tsc_snap = gpr->r14;
	unsigned __int64 const token_in = gpr->r15;

	if (vmcall_compute_token(guest_cr3, tsc_snap) != token_in)
	{
		if (ept::handler_vmcall_rip(*vcpu->ept_state))
			return;
		hv::inject_interruption(EXCEPTION_VECTOR_UNDEFINED_OPCODE, INTERRUPT_TYPE_HARDWARE_EXCEPTION, 0, false);
		return;
	}

	unsigned __int64 const enc_reason = gpr->rcx;
	vmcall_parameter1 = gpr->rdx;
	vmcall_parameter2 = gpr->r8;
	vmcall_parameter3 = gpr->r9;
	vmcall_parameter4 = gpr->r10;
	vmcall_parameter5 = gpr->r11;
	vmcall_parameter6 = gpr->r12;
	vmcall_parameter7 = gpr->r13;
	// R14/R15 reserved for TSC snapshot + token (AsmCallset).

#pragma optimize("g", off)
	for (unsigned i = 0; i < sizeof(g_vmcall_entries) / sizeof(g_vmcall_entries[0]); ++i)
	{
		if (g_vmcall_entries[i].enc != enc_reason)
			continue;
		status = g_vmcall_entries[i].fn(
			vcpu,
			vmcall_parameter1,
			vmcall_parameter2,
			vmcall_parameter3,
			vmcall_parameter4,
			vmcall_parameter5,
			vmcall_parameter6,
			vmcall_parameter7);
		goto vmcall_done;
	}
#pragma optimize("", on)

	hv::inject_interruption(EXCEPTION_VECTOR_UNDEFINED_OPCODE, INTERRUPT_TYPE_HARDWARE_EXCEPTION, 0, false);
	return;

vmcall_done:
	vcpu->vmexit_info.guest_registers->rax = status;
}