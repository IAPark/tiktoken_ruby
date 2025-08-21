package rcd_test;

import org.jruby.Ruby;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.anno.JRubyModule;
import org.jruby.runtime.ThreadContext;

@JRubyModule(name = "RcdTest")
public class RubyRcdTest {
    @JRubyMethod(name = "do_something", module = true, meta = true)
    public static IRubyObject buildSelfString(ThreadContext context, IRubyObject recv) {
        Ruby runtime = context.getRuntime();
        return runtime.newString("something has been done");
    }
}
