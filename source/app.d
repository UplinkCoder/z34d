import std.stdio;
import core.stdc.stdlib;
import z3;

void main()
{
	display_version();
	demorgan();
    x_xor_o_eq_not_x();
}


Z3_solver mk_solver(Z3_context ctx)
{
  Z3_solver s = Z3_mk_solver(ctx);
  Z3_solver_inc_ref(ctx, s);
  return s;
}

void del_solver(Z3_context ctx, Z3_solver s)
{
  Z3_solver_dec_ref(ctx, s);
}

void display_version()
{
    uint major, minor, build, revision;
    Z3_get_version(&major, &minor, &build, &revision);
    printf("Z3 %d.%d.%d.%d\n", major, minor, build, revision);
}

/**
   \brief Check whether the logical context is satisfiable, and compare the result with the expected result.
   If the context is satisfiable, then display the model.
*/

void check(Z3_context ctx, Z3_solver s, Z3_lbool expected_result)
{
    Z3_model m      = null;
    Z3_lbool result = Z3_solver_check(ctx, s);
    final switch (result) {
    case Z3_L_FALSE:
        printf("unsat\n");
        break;
    case Z3_L_UNDEF:
        printf("unknown\n");
        m = Z3_solver_get_model(ctx, s);
        if (m) Z3_model_inc_ref(ctx, m);
        printf("potential model:\n%s\n", Z3_model_to_string(ctx, m));
        break;
    case Z3_L_TRUE:
        m = Z3_solver_get_model(ctx, s);
        if (m) Z3_model_inc_ref(ctx, m);
        printf("sat\n%s\n", Z3_model_to_string(ctx, m));
        break;
    }
    if (result != expected_result) {
        printf("unexpected result");
	exit(0);
    }
    if (m) Z3_model_dec_ref(ctx, m);
}

/**
  Demonstration of how Z3 can be used to prove validity of
  De Morgan's Duality Law: {e not(x and y) <-> (not x) or ( not y) }
*/
void demorgan()
{
    Z3_config cfg;
    Z3_context ctx;
    Z3_solver s;
    Z3_sort bool_sort;
    Z3_symbol symbol_x, symbol_y;
    Z3_ast x, y, not_x, not_y, x_and_y, ls, rs, conjecture, negated_conjecture;
    Z3_ast[2] args;

    printf("\nDeMorgan\n");

    cfg                = Z3_mk_config();
    Z3_set_param_value(cfg, "proof", "true");
    ctx                = Z3_mk_context(cfg);
    Z3_del_config(cfg);
    bool_sort          = Z3_mk_bool_sort(ctx);
    symbol_x           = Z3_mk_string_symbol(ctx, "x");
    symbol_y           = Z3_mk_string_symbol(ctx, "y");
    x                  = Z3_mk_const(ctx, symbol_x, bool_sort);
    y                  = Z3_mk_const(ctx, symbol_y, bool_sort);

    /* De Morgan - with a negation around */
    /* !(!(x && y) <-> (!x || !y)) */
    not_x              = Z3_mk_not(ctx, x);
    not_y              = Z3_mk_not(ctx, y);
    args[0]            = x;
    args[1]            = y;
    x_and_y            = Z3_mk_and(ctx, 2, &args[0]);
    ls                 = Z3_mk_not(ctx, x_and_y);
    args[0]            = not_x;
    args[1]            = not_y;
    rs                 = Z3_mk_or(ctx, 2, &args[0]);
    conjecture         = Z3_mk_iff(ctx, ls, rs);
    negated_conjecture = Z3_mk_not(ctx, conjecture);

    s = mk_solver(ctx);
    Z3_solver_assert(ctx, s, negated_conjecture);

    final switch (Z3_solver_check(ctx, s)) {
    case Z3_L_FALSE:
        /* The negated conjecture was unsatisfiable, hence the conjecture is valid */
        printf("DeMorgan is valid\n");
        break;
    case Z3_L_UNDEF:
        /* Check returned undef */
        printf("Undef\n");
        break;
    case Z3_L_TRUE:
        /* The negated conjecture was satisfiable, hence the conjecture is not valid */
        printf("DeMorgan is not valid\n");
        break;
    }
    //auto m = Z3_solver_get_proof(ctx, s);
    printf("%s\n", Z3_ast_to_string(ctx, conjecture));
    del_solver(ctx, s);
    Z3_del_context(ctx);
}
void x_xor_o_eq_not_x()
{
    auto cfg                = Z3_mk_config();
    Z3_set_param_value(cfg, "proof", "true");
    auto ctx                = Z3_mk_context(cfg);
    Z3_del_config(cfg);
    auto bool_sort          = Z3_mk_bool_sort(ctx);
    auto symbol_x           = Z3_mk_string_symbol(ctx, "x");
    auto symbol_y           = Z3_mk_string_symbol(ctx, "y");
    auto x                  = Z3_mk_const(ctx, symbol_x, bool_sort);
    //auto y                  = Z3_mk_const(ctx, symbol_y, int_sort);
    auto ls                 = Z3_mk_xor(ctx, x, Z3_mk_true(ctx));
    auto rs                 = Z3_mk_not(ctx, x);
    auto conjecture         = Z3_mk_iff(ctx, ls, rs);

    auto negated_conjecture = Z3_mk_not(ctx, conjecture);
    printf("Conjecture: %s\n", Z3_ast_to_string(ctx, conjecture));

    auto s = mk_solver(ctx);
    Z3_solver_assert(ctx, s, negated_conjecture);

    final switch (Z3_solver_check(ctx, s)) {
        case Z3_L_FALSE:
            /* The negated conjecture was unsatisfiable, hence the conjecture is valid */
            printf("Conjecture is valid\n");
            break;
        case Z3_L_UNDEF:
            /* Check returned undef */
            printf("Undef\n");
            break;
        case Z3_L_TRUE:
            /* The negated conjecture was satisfiable, hence the conjecture is not valid */
            printf("Conjecture is not valid\n");
            break;
    }
    //auto m = Z3_solver_get_proof(ctx, s);
    del_solver(ctx, s);
    Z3_del_context(ctx);

}
