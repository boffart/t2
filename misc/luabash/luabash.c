/*
 * --- T2-COPYRIGHT-NOTE-BEGIN ---
 * This copyright note is auto-generated by ./scripts/Create-CopyPatch.
 * 
 * T2 SDE: luabash.c
 * Copyright (C) 2006 The T2 SDE Project
 * 
 * More information can be found in the files COPYING and README.
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License. A copy of the
 * GNU General Public License can be found in the file COPYING.
 * --- T2-COPYRIGHT-NOTE-END ---
 */


// compile with:
// gcc -shared -fPIC -Wall -o luabash.so luabash.c -llua -lm -Wall -ldl

/* Some declarations copied from bash-3.1 headers */

#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"


#define EXECUTION_SUCCESS 0
#define EXECUTION_FAILURE 1

typedef struct word_desc {
  char *word;
  int flags;
} WORD_DESC;

typedef struct word_list {
  struct word_list *next;
  WORD_DESC *word;
} WORD_LIST;

typedef int sh_builtin_func_t(WORD_LIST *);

#define BUILTIN_ENABLED 0x1
#define STATIC_BUILTIN  0x4	/* This builtin is not dynamically loaded. */
#define SPECIAL_BUILTIN 0x8	/* This is a Posix `special' builtin. */

struct builtin {
  char *name;
  sh_builtin_func_t *function;
  int flags;
  char * const *long_doc;
  const char *short_doc;
  char *handle;
};

struct variable;
typedef intmax_t arrayind_t;

typedef struct variable *sh_var_value_func_t(struct variable *);
typedef struct variable *sh_var_assign_func_t(struct variable *, char *, arrayind_t);

typedef struct variable {
  char *name;
  char *value;
  char *exportstr;
  sh_var_value_func_t *dynamic_value;
  sh_var_assign_func_t *assign_func;
  int attributes;
  int context;
} SHELL_VAR;


typedef struct redirect {
  int data;  // this is not quite true, but we don't need 'em here...
} REDIRECT;

struct simple_com;
struct function_def;

/* Command Types: */
enum command_type { cm_for, cm_case, cm_while, cm_if, cm_simple, cm_select,
                    cm_connection, cm_function_def, cm_until, cm_group,
                    cm_arith, cm_cond, cm_arith_for, cm_subshell };

typedef struct command {
  enum command_type type;       /* FOR CASE WHILE IF CONNECTION or SIMPLE. */
  int flags;                    /* Flags controlling execution environment. */
  int line;                     /* line number the command starts on */
  REDIRECT *redirects;          /* Special redirects for FOR CASE, etc. */
  union { // SNIP !!! we only need two of those structs here
    struct simple_com *Simple;
    struct function_def *Function_def;
  } value;
} COMMAND;


/* The "simple" command.  Just a collection of words and redirects. */
typedef struct simple_com {
  int flags;                    /* See description of CMD flags. */
  int line;                     /* line number the command starts on */
  WORD_LIST *words;             /* The program name, the arguments,
                                   variable assignments, etc. */
  REDIRECT *redirects;          /* Redirections to perform. */
} SIMPLE_COM;


/* The "function definition" command. */
typedef struct function_def {
  int flags;                    /* See description of CMD flags. */
  int line;                     /* Line number the function def starts on. */
  WORD_DESC *name;              /* The name of the function. */
  COMMAND *command;             /* The parsed execution tree. */
  char *source_file;            /* file in which function was defined, if any */
} FUNCTION_DEF;


extern WORD_DESC *make_word __P((const char *));
extern COMMAND *make_command __P((enum command_type, SIMPLE_COM *));
extern COMMAND *make_function_def __P((WORD_DESC *, COMMAND *, int, int));
extern int execute_command __P((COMMAND *));

extern SHELL_VAR* find_variable(const char *);
extern SHELL_VAR* bind_variable(const char *, const char *);
extern SHELL_VAR* bind_function __P((const char *, COMMAND *));
extern SHELL_VAR** all_shell_variables __P((void));
#define value_cell(var) ((var)->value)

extern int num_shell_builtins;	/* Number of shell builtins. */
extern struct builtin static_shell_builtins[];
extern struct builtin* shell_builtins;
extern void initialize_shell_builtins __P((void));
extern struct builtin* builtin_address_internal __P((char *, int));


extern void add_alias __P((const char *, const char *));




#ifdef DO_DYNAMIC_REGISTRATION

/* dynamic registration, not needed anymore.
 * want to keep that code, one never knows if we might need it again!
 *
 * Valentin.
 */

static int inject_new_builtin (struct builtin* b)
{
  struct builtin* old_builtin;

  b->flags |= STATIC_BUILTIN;
  /*if (flags & SPECIAL)
    b->flags |= SPECIAL_BUILTIN;*/
   
  if ( (old_builtin = builtin_address_internal (b->name, 1)) != 0 ) {
    memcpy ((void*) old_builtin, b, sizeof (struct builtin));
  } else {
    int total = num_shell_builtins + 1;
    int size = (total + 1) * sizeof (struct builtin);

    struct builtin* new_shell_builtins = (struct builtin*) malloc (size);
    memcpy ((void*) new_shell_builtins, (void*) shell_builtins,
	    num_shell_builtins * sizeof (struct builtin));
    memcpy ((void*) &new_shell_builtins[num_shell_builtins], (void*)b, sizeof (struct builtin));
    new_shell_builtins[total].name = (char *)0;
    new_shell_builtins[total].function = (sh_builtin_func_t *)0;
    new_shell_builtins[total].flags = 0;
      
    if (shell_builtins != static_shell_builtins)
      free (shell_builtins);

    shell_builtins = new_shell_builtins;
    num_shell_builtins = total;
    initialize_shell_builtins ();
  }

  return EXECUTION_SUCCESS;
}

#endif

/* helpers to work with variables, thanks to clifford */

static const char *getvar(const char *name)
{
	SHELL_VAR *var;
	var = find_variable(name);
	return var ? value_cell(var) : 0;
}

#define setvar(a,b) bind_variable(a,b)




/* lua bash wrapper */

#define LUABASH_VERSION "lua bash wrapper version 0.0.1; (C) 2006 Valentin Ziegler."

#define LUA_ERRMSG fprintf(stderr, "lua bash error: %s\n", lua_tostring(L, -1))
#define LUA_ERRMSG_FAIL {LUA_ERRMSG; return EXECUTION_FAILURE;}

char* luabash_doc[] = {
  LUABASH_VERSION,
  "usage:",
  "\tinit",
  "\tload <lua chunk>",
  "\tcall <lua function> [arguments]",
  (char*) 0
};

static int initialized=0;
static lua_State* L;

static void print_usage()
{
  int i=0;
  while(luabash_doc[i])
    fprintf(stderr, "%s\n", luabash_doc[i++]);
}

static int register_function (lua_State *L)
{
  const char* fnname = luaL_checkstring(L, 1);

  // old code using aliases
  //const char* fmt="luabash call %s ";
  //char* fullname=(char*) malloc(strlen(fmt)+strlen(fnname));
  //sprintf(fullname, fmt, fnname);
  //add_alias(fnname, fullname);

  WORD_LIST* wluabash=(WORD_LIST*) malloc(sizeof(WORD_LIST));
  WORD_LIST* wcall=(WORD_LIST*) malloc(sizeof(WORD_LIST));
  WORD_LIST* wfnname=(WORD_LIST*) malloc(sizeof(WORD_LIST));
  WORD_LIST* warguments=(WORD_LIST*) malloc(sizeof(WORD_LIST));
  wluabash->next = wcall;
  wcall->next=wfnname;
  wfnname->next=warguments;
  warguments->next=0;
  wluabash->word=make_word("luabash");
  wcall->word=make_word("call");
  wfnname->word=make_word(fnname);
  warguments->word=make_word("$@");

  SIMPLE_COM* call_luabash=(SIMPLE_COM*) malloc(sizeof(SIMPLE_COM));
  call_luabash->flags=0;
  call_luabash->line=0;
  call_luabash->redirects=NULL;
  call_luabash->words=wluabash;

  COMMAND* function_body=make_command(cm_simple, call_luabash);
  bind_function(fnname,function_body);

  return 0;
}

static int get_variable (lua_State *L)
{
  const char* vname = luaL_checkstring(L, 1);
  lua_pushstring(L, getvar(vname));
  return 1;
}

static int set_variable (lua_State *L)
{
  const char* vname = luaL_checkstring(L, 1);
  const char* vvalue = luaL_checkstring(L, 2);
  setvar(vname, vvalue);
  return 0;
}

static int call_bashfunction (lua_State *L)
{
  int no_args=lua_gettop(L);
  int retval=0;
  int i;

  WORD_LIST* list=0;
  WORD_LIST* start=0;

  for (i=0; i<no_args; i++) {
    const char* string=luaL_checkstring(L, i+1);
    if (list) {
      list->next=(WORD_LIST*) malloc(sizeof(WORD_LIST));
      list=list -> next;
    } else {
      list=(WORD_LIST*) malloc(sizeof(WORD_LIST));
      start=list;
    }
    list->word=make_word(string);
    list->next=0;
  }

  if (!list)
    retval=127;
  else {
    SIMPLE_COM* cmd=(SIMPLE_COM*) malloc(sizeof(SIMPLE_COM));
    cmd->flags=0;
    cmd->line=0;
    cmd->redirects=NULL;
    cmd->words=start;
    retval=execute_command(make_command(cm_simple, cmd));
  }
  lua_pushinteger(L,retval);
  return 1;
}

static int get_environment (lua_State *L)
{
  SHELL_VAR** list=all_shell_variables();
  int i=0;

  lua_newtable(L);
  while(list && list[i]) {
    const char* key=list[i]->name;
    const char* val=list[i]->value;
    lua_pushstring(L,val);
    lua_setfield(L,-2,key);
    i++;
  }

  return 1;
}

static const luaL_Reg bashlib[] = {
  {"register", register_function},
  {"getVariable",get_variable},
  {"setVariable",set_variable},
  {"getEnvironment",get_environment},
  {"call",call_bashfunction},
  {NULL, NULL}
};

static int init_luabash()
{
  if (!initialized) {
    L=luaL_newstate ();
    if (!L) {
      fprintf(stderr, "lua bash error: failed to initialize lua state\n");
      return EXECUTION_FAILURE;     
    }

    luaL_openlibs(L);
    luaL_register(L, "bash", bashlib);
    
    initialized=1;
  }

  return EXECUTION_SUCCESS;
}

static int load_chunk(const char* filename)
{
  int result=init_luabash();
  if (result != EXECUTION_SUCCESS)
    return result;

  if (luaL_loadfile(L, filename) || lua_pcall(L, 0, 0, 0))
    LUA_ERRMSG_FAIL;

  return EXECUTION_SUCCESS;
}

static int call_function(const char* func, WORD_LIST *args)
{
  if (!initialized) {
    fprintf(stderr, "lua bash error: not initialized yet!\n");
    return EXECUTION_FAILURE;
  }

  lua_getfield(L, LUA_GLOBALSINDEX, func);
  int no_args=0;
  while (args) {
    if (args->word->word) {
      lua_pushstring(L, args->word->word);
      no_args++;
    }
    args=args -> next;
  }

  if (lua_pcall(L, no_args, 0, 0))
    LUA_ERRMSG_FAIL;

  return EXECUTION_SUCCESS;
}


int luabash_builtin(WORD_LIST *list)
{
  if (list  && (list->word->word)) {
    char* command=list->word->word;
    if (strcmp(command, "init") == 0) {
      return init_luabash();
    } else if (strcmp(command, "load") == 0) {
      list=list->next;
      if (list && (list->word->word))
	return load_chunk(list->word->word);
    } else if (strcmp(command, "call") == 0) {
      list=list->next;
      if (list && (list->word->word))
	return call_function(list->word->word, list->next);
    }
  }

  print_usage();
  return EXECUTION_FAILURE;
}



struct builtin luabash_struct = {
	"luabash",
	&luabash_builtin,
	BUILTIN_ENABLED,
	luabash_doc,
	LUABASH_VERSION,
	0
};

