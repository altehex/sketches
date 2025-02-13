#include <erl_nif.h>

#include "fprintf.h"

#include <sys/termios.h>


struct termios termAttrs;

ErlNifResourceType * structTermiosType;

ERL_NIF_TERM ok;


static ERL_NIF_TERM
tcgetattr_ex(      ErlNifEnv *  env,
			       int          argc,
			 const ERL_NIF_TERM argv[])
{
	int fileDesc;
	struct termios * termAttrsRes;
	
	ERL_NIF_TERM termAttrsResTerm;

	if ( ! enif_get_int(env, argv[0], &fileDesc))
		return enif_make_badarg(env);
	
	if (tcgetattr(fileDesc, &termAttrs))
		return enif_raise_exception(env,
			enif_make_atom(env, "error"));

	termAttrsRes = enif_alloc_resource(structTermiosType, sizeof(struct termios));
	*termAttrsRes = termAttrs;
	
	termAttrsResTerm = enif_make_resource(env, termAttrsRes);
	
	enif_release_resource(termAttrsRes);
	
	return termAttrsResTerm;
}


static ErlNifFunc functions[] = {
	{"tcgetattr", 1, tcgetattr_ex}
};


int
load(ErlNifEnv *  env,
	 void * *     priv_data,
	 ERL_NIF_TERM load_info)
{
	ok = enif_make_atom(env, "ok");
	
	structTermiosType =
		enif_open_resource_type(
		    env, NULL, "struct_termios", NULL,
			  ERL_NIF_RT_CREATE
			| ERL_NIF_RT_TAKEOVER,
			NULL
        );
	
	// Мьютексы тут создавать
	
	return 0;
}


ERL_NIF_INIT(Elixir.Tax.Utils.Termios,
			 functions,
			 load, NULL, NULL, NULL)
