#include "rcd_test_ext.h"

#ifndef __has_builtin
  #define __has_builtin(x) 0
#endif

VALUE rb_mRcdTest;

static VALUE
rcdt_isinf_eh(VALUE self, VALUE rb_float) {
  Check_Type(rb_float, T_FLOAT);

  return isinf(RFLOAT_VALUE(rb_float)) ? Qtrue : Qfalse;
}

static VALUE
rcdt_isnan_eh(VALUE self, VALUE rb_float) {
  Check_Type(rb_float, T_FLOAT);

  return isnan(RFLOAT_VALUE(rb_float)) ? Qtrue : Qfalse;
}

static VALUE
rcdt_do_something(VALUE self)
{
  return rb_str_new_cstr("something has been done");
}

static VALUE
rcdt_darwin_builtin_available_eh(VALUE self)
{
#if __has_builtin(__builtin_available)
  // This version must be higher than MACOSX_DEPLOYMENT_TARGET to prevent clang from optimizing it away
  if (__builtin_available(macOS 10.14, *)) {
    return Qtrue;
  }
  return Qfalse;
#else
  rb_raise(rb_eRuntimeError, "__builtin_available is not defined");
#endif
}

static VALUE
rcdt_largefile_op_removed_from_musl(VALUE self)
{
  // Reference a symbol that was removed in Musl 1.24 🙄
  // https://github.com/sparklemotion/sqlite3-ruby/issues/434
#ifdef __linux__
  posix_fallocate(STDERR_FILENO, 0, 0);
  return Qtrue;
#else
  return Qfalse;
#endif
}

void
Init_rcd_test_ext(void)
{
  rb_mRcdTest = rb_define_module("RcdTest");
  rb_define_singleton_method(rb_mRcdTest, "do_something", rcdt_do_something, 0);
  rb_define_singleton_method(rb_mRcdTest, "darwin_builtin_available?", rcdt_darwin_builtin_available_eh, 0);
  rb_define_singleton_method(rb_mRcdTest, "isinf?", rcdt_isinf_eh, 1);
  rb_define_singleton_method(rb_mRcdTest, "isnan?", rcdt_isnan_eh, 1);
  rb_define_singleton_method(rb_mRcdTest, "largefile_op_removed_from_musl", rcdt_largefile_op_removed_from_musl, 0);
}
