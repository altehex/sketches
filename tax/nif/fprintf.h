#ifndef __FPRINTF_HPP
#define __FPRINTF_HPP


#define PRINT(FMT, ...) \
	enif_fprintf(stdout, FMT, __VA_ARGS__)


#endif // ! __FPRINTF_HPP
