#include <sigc++/sigc++.h>
#include <iostream>

void example_callback() {
    std::cout << "Hello World" << std::endl;
}

sigc::signal<void(void)> signal_say_hi;

int main() {
    // Register callback
    signal_say_hi.connect(sigc::ptr_fun(&example_callback));

    // Emit signal, so that callback gets called
    signal_say_hi.emit();

    return 0;
}
