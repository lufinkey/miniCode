
#include "Thread.h"
#include <unistd.h>
#include "../ObjCBridge/ObjCBridge.h"

void* Thread_Handler(void*data)
{
	void*pool = NSAutoReleasePool_alloc_init();
	Thread*thread = (Thread*)data;
	thread->run();
	thread->alive = false;
	thread->finish();
	id_release(pool);
	return NULL;
}

Thread::Thread()
{
	alive = false;
}

Thread::~Thread()
{
	if(alive)
	{
		pthread_join(thread, NULL);
	}
}

void Thread::run()
{
	//Open for implementation
}

void Thread::finish()
{
	//Open for implementation
}

void Thread::start()
{
	if(!alive)
	{
		alive = true;
		pthread_create(&thread, NULL, &Thread_Handler, this);
	}
}

void Thread::join()
{
	if(alive)
	{
		pthread_join(thread, NULL);
	}
}

void Thread::sleep(unsigned long millis)
{
	unsigned long micros = millis*1000;
	usleep(micros);
}

bool Thread::isAlive()
{
	return alive;
}
