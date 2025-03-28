/* zconf.h -- configuration of the zlib compression library
 * Copyright (C) 1995-2024 Jean-loup Gailly, Mark Adler
 * For conditions of distribution and use, see copyright notice in zlib.h
 */

using System;
using System.Interop;

namespace zlib;

extension zlib
{
#if Z_SOLO

#if _WIN64
	typealias z_size_t = c_ulonglong;
#else
	typealias z_size_t = c_ulong;
#endif

#else
	typealias z_longlong = c_ulonglong;

#if NO_SIZE_T
	typealias z_size_t = unsigned;
#elif STDC
	typealias z_size_t = size_t;
#else
	typealias z_size_t = c_ulong;
#endif

#endif

/* Maximum value for memLevel in deflateInit2 */
#if !MAX_MEM_LEVEL

#if MAXSEG_64K
	const int MAX_MEM_LEVEL = 8;
#else
	const int MAX_MEM_LEVEL = 9;
#endif

#endif

	/* Maximum value for windowBits in deflateInit2 and inflateInit2.
	* WARNING: reducing MAX_WBITS makes minigzip unable to extract .gz files
	* created by gzip. (Files created by minigzip can still be extracted by
	* gzip.)
	*/
#if !MAX_WBITS
	const int MAX_WBITS = 15; /* 32K LZ77 window */
#endif

	/* The memory requirements for deflate are (in bytes):
				(1 << (windowBits+2)) +  (1 << (memLevel+9))
	that is: 128K for windowBits=15  +  128K for memLevel = 8  (default values)
	plus a few kilobytes for small objects. For example, if you want to reduce
	the default memory requirements from 256K to 128K, compile with
		make CFLAGS="-O -DMAX_WBITS=14 -DMAX_MEM_LEVEL=7"
	Of course this will generally degrade compression (there's no free lunch).

	The memory requirements for inflate are (in bytes) 1 << windowBits
	that is, 32K for windowBits=15 (default value) plus about 7 kilobytes
	for small objects.
	*/

							/* Type declarations */

	// #if !OF /* function prototypes */
	// #if STDC
	// #    define OF(args)  args
	// #else
	// #    define OF(args)  ()
	// #endif
	// #endif

	/* The following definitions for FAR are needed only for MSDOS mixed
	* model programming (small or medium model with some far allocations).
	* This was tested only with MSC; for other MSDOS compilers you may have
	* to define NO_MEMCPY in zutil.h.  If you don't need the mixed model,
	* just define FAR to be empty.
	*/
	// #if SYS16BIT
	// #if M_I86SM || M_I86MM
	//     /* MSC small or medium model */
	// #    define SMALL_MEDIUM
	// #    if _MSC_VER
	// #      define FAR _far
	// #    else
	// #      define FAR far
	// #    endif
	// #endif
	// #if (__SMALL__ || __MEDIUM__)
	//     /* Turbo C small or medium model */
	// #    define SMALL_MEDIUM
	// #    if __BORLANDC__
	// #      define FAR _far
	// #    else
	// #      define FAR far
	// #    endif
	// #endif
	// #endif

	typealias Byte = c_uchar; /* 8 bits */
	typealias Bytef = Byte; /* 8 bits */
	typealias uInt = c_uint; /* 16 bits or more */
	typealias uLong = c_ulong; /* 32 bits or more */

	typealias charf = char;
	typealias intf = int;
	typealias uIntf = uInt;
	typealias uLongf = uLong;

	typealias voidpc = void*;
	typealias voidpf = void*;
	typealias voidp = void*;

	// #if !Z_U4 && !Z_SOLO && STDC
	// #  include <limits.h>
	// #if (UINT_MAX == 0xffffffffUL)
	// #    define Z_U4 unsigned
	// #  elif (ULONG_MAX == 0xffffffffUL)
	// #    define Z_U4 c_ulong
	// #  elif (USHRT_MAX == 0xffffffffUL)
	// #    define Z_U4 unsigned short
	// #endif
	// #endif

	// #if Z_U4
	// typealias z_crc_t = Z_U4;
	// #else
	typealias z_crc_t = c_ulong;
	// #endif

#if !SEEK_SET && !Z_SOLO
	const int SEEK_SET        = 0; /* Seek from beginning of file.  */
	const int SEEK_CUR        = 1; /* Seek from current position.  */
	const int SEEK_END        = 2; /* Set file pointer to EOF plus "offset" */
#endif

	typealias z_off_t = c_longlong;

// #if !_WIN32 && Z_LARGE64
//     typealias z_off64_t = off64_t;
// #elif __MINGW32__
//     typealias z_off64_t = long long;
// #elif _WIN32 && !__GNUC__
//     typealias z_off64_t = __int64;
// #elif __GO32__
//     typealias z_off64_t = offset_t;
// #else
	typealias z_off64_t = z_off_t;
// #endif
}