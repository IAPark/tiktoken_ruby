package rcd_test;

import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.runtime.ObjectAllocator;
import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.runtime.load.BasicLibraryService;

import java.io.IOException;

public class RcdTestExtService  implements BasicLibraryService {
    @Override
    public boolean basicLoad(final Ruby ruby) throws IOException {
        RubyModule rb_mRcdTest = ruby.defineModule("RcdTest");
        rb_mRcdTest.defineAnnotatedMethods(RubyRcdTest.class);
        return true;
    }
}
