#pragma once

#ifndef _VMCALL_OBFUSCATE_H
#define _VMCALL_OBFUSCATE_H

// Single build-wide XOR key for VMCall reason codes (RCX). Change per build / toolchain.
#ifndef VMCALL_REASON_XOR_KEY
#define VMCALL_REASON_XOR_KEY (0x7E3A9B2D5C8F1E40ULL)
#endif
#define vmcall_reason_encode(x) ((unsigned __int64)(unsigned int)(x) ^ (VMCALL_REASON_XOR_KEY))
#define vmcall_reason_decode(x) ((unsigned __int64)(x) ^ (VMCALL_REASON_XOR_KEY))

#endif // !_VMCALL_OBFUSCATE_H
