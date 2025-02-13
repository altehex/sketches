#include <erl_nif.h>

#include <unistd.h>


static ERL_NIF_TERM
isatty_ex(      ErlNifEnv *  env,
		        int          argc,
		  const ERL_NIF_TERM argv[])
{
	int desc,
	    isTty;

	if ( ! enif_get_int(env, argv[0], &desc))
		return enif_make_badarg(env);

	isTty = isatty(desc);

	if (isTty)
		return enif_make_atom(env, "true");

	return enif_make_atom(env, "false");
}


static ErlNifFunc functions[] = {
	{"isatty", 1, isatty_ex}
};


ERL_NIF_INIT(Elixir.Tax.Utils.Unistd,
			 functions,
			 NULL, NULL, NULL, NULL)
