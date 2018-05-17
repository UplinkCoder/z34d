import std.stdio;
import core.stdc.stdlib;
import z3;

void main()
{
	display_version();
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
