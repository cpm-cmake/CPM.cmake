#ifndef __SCOPED_LOCK_HPP
#define __SCOPED_LOCK_HPP

#include <boost/noncopyable.hpp>

// Helper class to lock and unlock a singleton automatically.

template <class T> class scoped_lock : private boost::noncopyable
{
public:
    explicit scoped_lock() { T::lock(); }
    ~scoped_lock() { T::unlock(); }
};

#endif
