#ifndef _XIPHOS_UEFI_H_
#define _XIPHOS_UEFI_H_


#include <types.h>


typedef PTR EFI_HANDLE;


struct _EfiTableHeader {
	U64  signature;
	U32  revision;
	U32  headerSize;
	U32  crc32;
	U32  _reserved;
};
typedef struct _EfiTableHeader EfiTableHeader;


struct _EfiBootServices {
	EfiTableHeader  header;
	PTR _placeholder;
};
typedef struct _EfiBootServices EfiBootServices;


struct _EfiRuntimeServices {
	EfiTableHeader  header;
	PTR _placeholder;
};
typedef struct _EfiRuntimeServices EfiRuntimeServices;


struct _EfiSystemTable {
	EfiTableHeader        header;
	PTR                   firmwareVendor;
	U32                   firmwareRevision;
	EFI_HANDLE            consoleInHandle;
	PTR                   consoleIn;
	EFI_HANDLE            consoleOutHandle;
	PTR                   consoleOut;
	EFI_HANDLE            stdErrHandle;
	PTR                   stdErr;
	EfiRuntimeServices *  runtimeServices;
	EfiBootServices *     bootServices;
	U64                   tableEntryNumber;
	EfiConfigTable *      configTable;
};
typedef struct _EfiSystemTable EfiSystemTable;


#endif /* !_XIPHOS_UEFI_H_ */
