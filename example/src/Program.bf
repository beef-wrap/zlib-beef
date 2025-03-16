using System;
using System.Collections;
using System.Diagnostics;
using System.IO;
using System.Interop;
using System.Text;

using static zlib.zlib;

namespace example;

static class Program
{
	typealias size_t = uint;

	typealias FILE = void*;

	[CLink] public static extern FILE fopen(char8* file, char8* mode);
	[CLink] public static extern c_int fread(void* buffer, size_t size, size_t count, FILE stream);
	[CLink] public static extern c_int fwrite(void* buffer, size_t size, size_t count, FILE stream);
	[CLink] public static extern bool ferror(FILE stream);
	[CLink] public static extern bool feof(FILE stream);
	/*
	zpipe.c: example of proper use of zlib's inflate() and deflate()
	Not copyrighted -- provided to the public domain
	Version 1.4  11 December 2005  Mark Adler
	*/

	/* Version history:
	   1.0  30 Oct 2004  First version
	   1.1   8 Nov 2004  Add void casting for unused return values
						 Use switch statement for inflate() return values
	   1.2   9 Nov 2004  Add assertions to document zlib guarantees
	   1.3   6 Apr 2005  Remove incorrect assertion in inf()
	   1.4  11 Dec 2005  Add hack to avoid MSDOS end-of-line conversions
						 Avoid some compiler warnings for input and output buffers
	 */

	const int CHUNK = 16384;

/* Compress from file source to file dest until EOF on source.
   def() returns Z_OK on success, Z_MEM_ERROR if memory could not be
   allocated for processing, Z_STREAM_ERROR if an invalid compression
   level is supplied, Z_VERSION_ERROR if the version of zlib.h and the
   version of the library linked do not match, or Z_ERRNO if there is
   an error reading or writing the files. */
	static int def(FILE source, FILE dest, c_int level)
	{
		c_int ret;
		c_int flush = 0;
		c_uint have;
		z_stream strm  = ?;
		c_uchar[CHUNK] in_ = ?;
		c_uchar[CHUNK] out_ = ?;

		/* allocate deflate state */
		strm.zalloc = Z_NULL;
		strm.zfree = Z_NULL;
		strm.opaque = (void*)null;

		ret = deflateInit2(&strm, level, Z_DEFLATED, 15 | 16, 8, Z_DEFAULT_STRATEGY);

		if (ret != Z_OK)
			return ret;

		/* compress until end of file */
		repeat
		{
			strm.avail_in = (.)fread(&in_, 1, CHUNK, source);
			if (ferror(source))
			{
				(void)deflateEnd(&strm);
				return Z_ERRNO;
			}
			flush = feof(source) ? Z_FINISH : Z_NO_FLUSH;
			strm.next_in = &in_;

			/* run deflate() on input until output buffer not full, finish
			   compression if all of source has been read in */
			repeat
			{
				strm.avail_out = CHUNK;
				strm.next_out = &out_;
				ret = deflate(&strm, flush); /* no bad return value */
				// assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
				have = CHUNK - strm.avail_out;
				if (fwrite(&out_, 1, have, dest) != (.)have || ferror(dest))
				{
					(void)deflateEnd(&strm);
					return Z_ERRNO;
				}
			} while (strm.avail_out == 0);
			// assert(strm.avail_in == 0);     /* all input will be used */

			/* done when last data in file processed */
		} while (flush != Z_FINISH);

		// assert(ret == Z_STREAM_END);        /* stream will be complete */

		/* clean up and return */
		(void)deflateEnd(&strm);

		return Z_OK;
	}

/* Decompress from file source to file dest until stream ends or EOF.
   inf() returns Z_OK on success, Z_MEM_ERROR if memory could not be
   allocated for processing, Z_DATA_ERROR if the deflate data is
   invalid or incomplete, Z_VERSION_ERROR if the version of zlib.h and
   the version of the library linked do not match, or Z_ERRNO if there
   is an error reading or writing the files. */
	static int inf(FILE source, FILE dest)
	{
		int ret;
		c_uint have;
		z_stream strm = .();
		c_uchar[CHUNK] in_ = ?;
		c_uchar[CHUNK] out_ = ?;

		/* allocate inflate state */
		strm.zalloc = Z_NULL;
		strm.zfree = Z_NULL;
		strm.opaque = null;
		strm.avail_in = 0;
		strm.next_in = null;
		ret = inflateInit(&strm);

		if (ret != Z_OK)
			return ret;

		/* decompress until deflate stream ends or end of file */
		repeat
		{
			strm.avail_in = (.)fread(&in_, 1, CHUNK, source);
			if (ferror(source))
			{
				(void)inflateEnd(&strm);
				return Z_ERRNO;
			}
			if (strm.avail_in == 0)
				break;
			strm.next_in = &in_;

			/* run inflate() on input until output buffer not full */
			repeat
			{
				strm.avail_out = CHUNK;
				strm.next_out = &out_;
				ret = inflate(&strm, Z_NO_FLUSH);
				//assert(ret != Z_STREAM_ERROR);  /* state not clobbered */
				switch (ret) {
				case Z_NEED_DICT:
					ret = Z_DATA_ERROR; /* and fall through */
				case Z_DATA_ERROR:
				case Z_MEM_ERROR:
					(void)inflateEnd(&strm);
					return ret;
				}
				have = CHUNK - strm.avail_out;
				if (fwrite(&out_, 1, have, dest) != (.)have || ferror(dest))
				{
					(void)inflateEnd(&strm);
					return Z_ERRNO;
				}
			} while (strm.avail_out == 0);

			/* done when inflate() says it's done */
		} while (ret != Z_STREAM_END);

	   // /* clean up and return */
		(void)inflateEnd(&strm);

		return ret == Z_STREAM_END ? Z_OK : Z_DATA_ERROR;
	}

/* report a zlib or i/o error */
	static void zerr(int ret)
	{
		Debug.WriteLine("zpipe: ");
		switch (ret) {
		case Z_ERRNO:
			/*if (ferror(stdin))
				Debug.WriteLine("error reading stdin\n");
			if (ferror(stdout))
				Debug.WriteLine("error writing stdout\n");*/
			break;
		case Z_STREAM_ERROR:
			Debug.WriteLine("invalid compression level\n");
			break;
		case Z_DATA_ERROR:
			Debug.WriteLine("invalid or incomplete deflate data\n");
			break;
		case Z_MEM_ERROR:
			Debug.WriteLine("out of memory\n");
			break;
		case Z_VERSION_ERROR:
			Debug.WriteLine("zlib version mismatch!\n");
		}
	}

	static int Main(params String[] args)
	{
		FILE src = fopen("src.txt", "rb");
		FILE deflated = fopen("src.z", "wb");

		/* do compression */
		let ret = def(src, deflated, Z_DEFAULT_COMPRESSION);

		if (ret != Z_OK)
			zerr(ret);

		return ret;
	}
}