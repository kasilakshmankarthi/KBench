//#include "atomics.h"
#ifndef __LH_ATOMICS_H_
#define __LH_ATOMICS_H_

#include <stdint.h>
//#define __aarch64__
//#define __x86_64__
#define USE_LSE

inline void spin_wait (unsigned long wait_iter) {
#if defined(__aarch64__)
	asm volatile(
	"1:	subs	%[wait_iter], %[wait_iter], #1\n"
	"	bcs	1b\n"
	: [wait_iter] "+&r" (wait_iter));
#else
	int i = 0;

	for (i = 0; i < wait_iter; i++) {
		asm("");
	}
#endif
}

inline void wait64 (unsigned long *lock, unsigned long val) {
#if defined(__aarch64__)
	unsigned long tmp;

	asm volatile(
	"	sevl\n"
	"1:	wfe\n"
	"	ldaxr	%[tmp], %[lock]\n"
	"	eor	%[tmp], %[tmp], %[val]\n"
	"	cbnz	%[tmp], 1b\n"
	: [tmp] "=&r" (tmp)
	: [lock] "Q" (*lock), [val] "r" (val)
	: );
#else
	volatile unsigned long *v = lock;

	while (*v != val);
#endif
}

inline void wait32 (uint32_t *lock, uint32_t val) {
#if defined(__aarch64__)
	uint32_t tmp;

	asm volatile(
	"	sevl\n"
	"1:	wfe\n"
	"	ldaxr	%w[tmp], %[lock]\n"
	"	eor	%w[tmp], %w[tmp], %w[val]\n"
	"	cbnz	%w[tmp], 1b\n"
	: [tmp] "=&r" (tmp)
	: [lock] "Q" (*lock), [val] "r" (val)
	: );
#else
	volatile uint32_t *v = lock;

	while (*v != val);
#endif
}

inline void prefetch64 (unsigned long *ptr) {
#if defined(__aarch64__)
	asm volatile("	prfm	pstl1keep, %[ptr]\n"
	:
	: [ptr] "Q" (*(unsigned long *)ptr));
#endif
}

inline unsigned long int fetchadd64_acquire_release (unsigned long *ptr, unsigned long val) {
#if defined(__x86_64__)
	asm volatile ("lock xaddq %q0, %1\n"
		      : "+r" (val), "+m" (*(ptr))
		      : : "memory", "cc");
#elif defined(__aarch64__)
#if defined(USE_LSE)
	unsigned long old;

	asm volatile(
	"	ldaddal	%[val], %[old], %[ptr]\n"
	: [old] "=&r" (old), [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "r" (val)
	: );

	val = old;
#else
	unsigned long tmp, old, newval;

	asm volatile(
	"1:	ldaxr	%[old], %[ptr]\n"
	"	add	%[newval], %[old], %[val]\n"
	"	stlxr	%w[tmp], %[newval], %[ptr]\n"
	"	cbnz	%w[tmp], 1b\n"
	: [tmp] "=&r" (tmp), [old] "=&r" (old), [newval] "=&r" (newval),
	  [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "Lr" (val)
	: );

	val = old;
#endif
#else
	/* TODO: builtin atomic call */
#endif

	return val;
}

inline unsigned long fetchadd64_acquire (unsigned long *ptr, unsigned long val) {
#if defined(__x86_64__)
	asm volatile ("lock xaddq %q0, %1\n"
		      : "+r" (val), "+m" (*(ptr))
		      : : "memory", "cc");
#elif defined(__aarch64__)
#if defined(USE_LSE)
	unsigned long old;

	asm volatile(
	"	ldadda	%[val], %[old], %[ptr]\n"
	: [old] "=&r" (old), [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "r" (val)
	: );

	val = old;
#else
	unsigned long tmp, old, newval;

	asm volatile(
	"1:	ldaxr	%[old], %[ptr]\n"
	"	add	%[newval], %[old], %[val]\n"
	"	stxr	%w[tmp], %[newval], %[ptr]\n"
	"	cbnz	%w[tmp], 1b\n"
	: [tmp] "=&r" (tmp), [old] "=&r" (old), [newval] "=&r" (newval),
	  [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "Lr" (val)
	: );

	val = old;
#endif
#else
	/* TODO: builtin atomic call */
#endif

	return val;
}

inline unsigned long fetchadd64_release (unsigned long *ptr, unsigned long val) {
#if defined(__x86_64__)
	asm volatile ("lock xaddq %q0, %1\n"
		      : "+r" (val), "+m" (*(ptr))
		      : : "memory", "cc");
#elif defined(__aarch64__)
#if defined(USE_LSE)
	unsigned long old;

	asm volatile(
	"	ldaddl	%[val], %[old], %[ptr]\n"
	: [old] "=&r" (old), [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "r" (val)
	: );

	val = old;
#else
	unsigned long tmp, old, newval;

	asm volatile(
	"1:	ldxr	%[old], %[ptr]\n"
	"	add	%[newval], %[old], %[val]\n"
	"	stlxr	%w[tmp], %[newval], %[ptr]\n"
	"	cbnz	%w[tmp], 1b\n"
	: [tmp] "=&r" (tmp), [old] "=&r" (old), [newval] "=&r" (newval),
	  [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "Lr" (val)
	: );

#endif
	val = old;
#else
	/* TODO: builtin atomic call */
#endif

	return val;
}

inline unsigned long fetchadd64 (unsigned long *ptr, unsigned long val) {
#if defined(__x86_64__)
	asm volatile ("lock xaddq %q0, %1\n"
		      : "+r" (val), "+m" (*(ptr))
		      : : "memory", "cc");
#elif defined(__aarch64__)
#if defined(USE_LSE)
	unsigned long old;

	asm volatile(
	"	ldadd	%[val], %[old], %[ptr]\n"
	: [old] "=&r" (old), [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "r" (val)
	: );

	val = old;
#else
	unsigned long tmp, old, newval;

	asm volatile(
	"1:	ldxr	%[old], %[ptr]\n"
	"	add	%[newval], %[old], %[val]\n"
	"	stxr	%w[tmp], %[newval], %[ptr]\n"
	"	cbnz	%w[tmp], 1b\n"
	: [tmp] "=&r" (tmp), [old] "=&r" (old), [newval] "=&r" (newval),
	  [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "Lr" (val)
	: );

	val = old;
#endif
#else
	/* TODO: builtin atomic call */
#endif

	return val;
}

inline unsigned long fetchsub64 (unsigned long *ptr, unsigned long val) {
#if defined(__x86_64__)
	val = (unsigned long) (-(long) val);

	asm volatile ("lock xaddq %q0, %1\n"
		      : "+r" (val), "+m" (*(ptr))
		      : : "memory", "cc");
#elif defined(__aarch64__)
#if defined(USE_LSE)
	unsigned long old;
	val = (unsigned long) (-(long) val);

	asm volatile(
	"	ldadd	%[val], %[old], %[ptr]\n"
	: [old] "=&r" (old), [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "r" (val)
	: );

	val = old;
#else
	unsigned long tmp, old, newval;

	asm volatile(
	"1:	ldxr	%[old], %[ptr]\n"
	"	sub	%[newval], %[old], %[val]\n"
	"	stxr	%w[tmp], %[newval], %[ptr]\n"
	"	cbnz	%w[tmp], 1b\n"
	: [tmp] "=&r" (tmp), [old] "=&r" (old), [newval] "=&r" (newval),
	  [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "Lr" (val)
	: );

	val = old;
#endif
#else
	/* TODO: builtin atomic call */
#endif

	return val;
}

inline unsigned long swap64 (unsigned long *ptr, unsigned long val) {
#if defined(__x86_64__)
	asm volatile ("xchgq %q0, %1\n"
		      : "+r" (val), "+m" (*(ptr))
		      : : "memory", "cc");
#elif defined(__aarch64__)
#if defined(USE_LSE)
	unsigned long old;

	asm volatile(
	"	swpal	%[val], %[old], %[ptr]\n"
	: [old] "=&r" (old), [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "r" (val)
	: );

	val = old;
#else
	unsigned long tmp, old;

	asm volatile(
	"1:	ldaxr	%[old], %[ptr]\n"
	"	stlxr	%w[tmp], %[val], %[ptr]\n"
	"	cbnz	%w[tmp], 1b\n"
	: [tmp] "=&r" (tmp), [old] "=&r" (old),
	  [ptr] "+Q" (*(unsigned long *)ptr)
	: [val] "r" (val)
	: );

	val = old;
#endif
#else
	/* TODO: builtin atomic call */
#endif

	return val;
}

inline unsigned long cas64 (unsigned long *ptr, unsigned long val, unsigned long exp) {
	unsigned long old;

#if defined(__x86_64__)
	asm volatile ("lock cmpxchgq %2, %1\n"
		      : "=a" (old), "+m" (*(ptr))
		      : "r" (val), "0" (exp)
		      : "memory");
#elif defined(__aarch64__)
#if defined(USE_LSE)
	asm volatile(
	"	mov	%[old], %[exp]\n"
	"	cas	%[old], %[val], %[ptr]\n"
	: [old] "=&r" (old), [ptr] "+Q" (*(unsigned long *)ptr)
	: [exp] "Lr" (exp), [val] "r" (val)
	: );
#else
	unsigned long tmp;

	asm volatile(
	"1:	ldxr	%[old], %[ptr]\n"
	"	eor	%[tmp], %[old], %[exp]\n"
	"	cbnz	%[tmp], 2f\n"
	"	stxr	%w[tmp], %[val], %[ptr]\n"
	"	cbnz	%w[tmp], 1b\n"
	"2:"
	: [tmp] "=&r" (tmp), [old] "=&r" (old),
	  [ptr] "+Q" (*(unsigned long *)ptr)
	: [exp] "Lr" (exp), [val] "r" (val)
	: );
#endif
#else
	/* TODO: builtin atomic call */
#endif

	return old;
}

inline unsigned long cas64_acquire (unsigned long *ptr, unsigned long val, unsigned long exp) {
	unsigned long old;

#if defined(__x86_64__)
	asm volatile ("lock cmpxchgq %2, %1\n"
		      : "=a" (old), "+m" (*(ptr))
		      : "r" (val), "0" (exp)
		      : "memory");
#elif defined(__aarch64__)
#if defined(USE_LSE)
	asm volatile(
	"	mov	%[old], %[exp]\n"
	"	casa	%[old], %[val], %[ptr]\n"
	: [old] "=&r" (old), [ptr] "+Q" (*(unsigned long *)ptr)
	: [exp] "Lr" (exp), [val] "r" (val)
	: );
#else
	unsigned long tmp;

	asm volatile(
	"1:	ldaxr	%[old], %[ptr]\n"
	"	eor	%[tmp], %[old], %[exp]\n"
	"	cbnz	%[tmp], 2f\n"
	"	stxr	%w[tmp], %[val], %[ptr]\n"
	"	cbnz	%w[tmp], 1b\n"
	"2:"
	: [tmp] "=&r" (tmp), [old] "=&r" (old),
	  [ptr] "+Q" (*(unsigned long *)ptr)
	: [exp] "Lr" (exp), [val] "r" (val)
	: );
#endif
#else
	/* TODO: builtin atomic call */
#endif

	return old;
}

inline unsigned long cas64_release (unsigned long *ptr, unsigned long val, unsigned long exp) {
	unsigned long old;

#if defined(__x86_64__)
	asm volatile ("lock cmpxchgq %2, %1\n"
		      : "=a" (old), "+m" (*(ptr))
		      : "r" (val), "0" (exp)
		      : "memory");
#elif defined(__aarch64__)
#if defined(USE_LSE)
	asm volatile(
	"	mov	%[old], %[exp]\n"
	"	casl	%[old], %[val], %[ptr]\n"
	: [old] "=&r" (old), [ptr] "+Q" (*(unsigned long *)ptr)
	: [exp] "Lr" (exp), [val] "r" (val)
	: );
#else
	unsigned long tmp;

	asm volatile(
	"1:	ldxr	%[old], %[ptr]\n"
	"	eor	%[tmp], %[old], %[exp]\n"
	"	cbnz	%[tmp], 2f\n"
	"	stlxr	%w[tmp], %[val], %[ptr]\n"
	"	cbnz	%w[tmp], 1b\n"
	"2:"
	: [tmp] "=&r" (tmp), [old] "=&r" (old),
	  [ptr] "+Q" (*(unsigned long *)ptr)
	: [exp] "Lr" (exp), [val] "r" (val)
	: );
#endif
#else
	/* TODO: builtin atomic call */
#endif

	return old;
}

inline unsigned long cas64_acquire_release (unsigned long *ptr, unsigned long val, unsigned long exp) {
	unsigned long old;

#if defined(__x86_64__)
	asm volatile ("lock cmpxchgq %2, %1\n"
		      : "=a" (old), "+m" (*(ptr))
		      : "r" (val), "0" (exp)
		      : "memory");
#elif defined(__aarch64__)
#if defined(USE_LSE)
	asm volatile(
	"	mov	%[old], %[exp]\n"
	"	casal	%[old], %[val], %[ptr]\n"
	: [old] "=&r" (old), [ptr] "+Q" (*(unsigned long *)ptr)
	: [exp] "Lr" (exp), [val] "r" (val)
	: );
#else
	unsigned long tmp;

	asm volatile(
	"1:	ldaxr	%[old], %[ptr]\n"
	"	eor	%[tmp], %[old], %[exp]\n"
	"	cbnz	%[tmp], 2f\n"
	"	stlxr	%w[tmp], %[val], %[ptr]\n"
	"	cbnz	%w[tmp], 1b\n"
	"2:"
	: [tmp] "=&r" (tmp), [old] "=&r" (old),
	  [ptr] "+Q" (*(unsigned long *)ptr)
	: [exp] "Lr" (exp), [val] "r" (val)
	: );
#endif
#else
	/* TODO: builtin atomic call */
#endif

	return old;
}

#endif // __LH_ATOMICS_H_
