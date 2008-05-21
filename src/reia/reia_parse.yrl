Nonterminals
  grammar
  statements
  exprs
  expr
  expr2
  expr3
  expr_ending
  ending_token
  erlang_funcall
  funcall
  add_op
  multi_op
  pow_op
  unary_expr
  primitive
  parenthesized_expr
  number
  list
  tuple
  dict
  entries
  .
  
Terminals
  true false nil 
  float integer string regexp atom identifier eol
  '(' ')' '[' ']' '{' '}' % '<<' '>>'
  '+' '-' '*' '/' '**'
  '.' ',' ':' '::' ';'
  '='
  .

Rootsymbol grammar.

grammar -> statements : '$1'.

%% Program expressions
statements -> expr : ['$1'].
statements -> expr expr_ending : ['$1'].
statements -> expr expr_ending statements : ['$1'|'$3'].

%% Expression endings
expr_ending -> ending_token : '$1'.
expr_ending -> expr_ending ending_token : '$1'.
ending_token -> ';' : '$1'.
ending_token -> eol : '$1'.

%% Expressions
exprs -> expr : ['$1'].
exprs -> expr ',' exprs : ['$1' | '$3'].

expr -> expr2 '=' expr : {match, line('$2'), '$1', '$3'}.
expr -> expr2 : '$1'.

expr2 -> erlang_funcall : '$1'.
expr2 -> expr3 : '$1'.

expr3 -> funcall : '$1'.
expr3 -> add_op : '$1'.

%% Erlang function calls
erlang_funcall -> identifier '::' identifier '(' ')' : {erl_funcall, line('$2'), '$1', '$3', []}.
erlang_funcall -> identifier '::' identifier '(' exprs ')' : {erl_funcall, line('$2'), '$1', '$3', '$5'}.

%% Function calls
funcall -> expr2 '.' identifier '(' ')' : {funcall, line('$2'), '$1', '$3', []}.
funcall -> expr2 '.' identifier '(' exprs ')' : {funcall, line('$2'), '$1', '$3', '$5'}.

%% Additive operators
add_op -> multi_op : '$1'.
add_op -> add_op '+' multi_op : {op, '$2', '$1', '$3'}.
add_op -> add_op '-' multi_op : {op, '$2', '$1', '$3'}.

%% Multiplicative operators
multi_op -> pow_op : '$1'.
multi_op -> multi_op '*' pow_op : {op, '$2', '$1', '$3'}.
multi_op -> multi_op '/' pow_op : {op, '$2', '$1', '$3'}.

%% Exponent operator
pow_op -> unary_expr : '$1'.
pow_op -> pow_op '**' unary_expr : {op, '$2', '$1', '$3'}.

%% Unary operators
unary_expr -> primitive : '$1'.
unary_expr -> '+' unary_expr : {op, '$1', '$2'}.
unary_expr -> '-' unary_expr : {op, '$1', '$2'}.

%% Simple exprs
primitive -> identifier : '$1'.
primitive -> nil        : '$1'.
primitive -> true       : '$1'.
primitive -> false      : '$1'.
primitive -> number     : '$1'.
primitive -> string     : '$1'.
primitive -> regexp     : '$1'.
primitive -> list       : '$1'.
primitive -> tuple      : '$1'.
primitive -> dict       : '$1'.
primitive -> atom       : '$1'.

%% Parens for explicit order of operation
primitive -> parenthesized_expr : '$1'.
parenthesized_expr -> '(' expr ')' : '$2'.

%% Numbers
number -> float : '$1'.
number -> integer : '$1'.

%% Lists
list -> '[' ']' : {list, line('$1'), []}.
list -> '[' exprs ']' : {list, line('$1'), '$2'}.

%% Tuples
tuple -> '(' ')' : {tuple, line('$1'), []}.
tuple -> '(' expr ',' ')' : {tuple, line('$1'), ['$2']}.
tuple -> '(' expr ',' exprs ')': {tuple, line('$1'), ['$2'|'$4']}.

%% Dicts
dict -> '{' '}' : {dict, line('$1'), []}.
dict -> '{' entries : {dict, line('$1'), '$2'}.

entries -> 'expr3' ':' expr '}' : [{tuple, line('$2'), ['$1','$3']}].
entries -> expr3 ':' expr ',' entries : [{tuple, line('$2'), ['$1','$3']}|'$5'].

Erlang code.

%% keep track of line info in tokens
line(Tup) -> element(2, Tup).