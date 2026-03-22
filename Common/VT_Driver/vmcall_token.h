#pragma once

#ifndef _VMCALL_TOKEN_H
#define _VMCALL_TOKEN_H

#include <intrin.h>

// Dynamic vmcall authentication: no fixed magic in .rdata.
// Guest entry (AsmCallset) must place R14 = TSC snapshot, R15 = token using this exact mix.
// Hypervisor recomputes from vmread(GUEST_CR3) and guest R14.

inline unsigned __int64 vmcall_compute_token(unsigned __int64 cr3, unsigned __int64 tsc) noexcept
{
	unsigned __int64 const id = tsc ^ (tsc >> 32);
	return (id ^ cr3) + (tsc >> 32);
}

#endif
