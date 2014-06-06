
#include "Thread.h"
#include "SDL_timer.h"
#include "SDL_thread.h"
#include "../ObjCBridge/ObjCBridge.h"

int ThreadHandler(void*data)
{
	void*pool = NSAutoReleasePool_alloc_init();
	Thread*thread = (Thread*)data;
	thread->run();
	thread->alive = false;
	thread->finish();
	id_release(pool);
	return 0;
}

Thread::Thread()
{
	alive = false;
	thread = NULL;
}

Thread::~Thread()
{
	if(thread!=NULL)
	{
		SDL_WaitThread((SDL_Thread*)thread, NULL);
		thread = NULL;
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
		if(thread!=NULL)
		{
			SDL_WaitThread((SDL_Thread*)thread, NULL);
			thread = NULL;
		}
		
		alive = true;
		
		thread = (void*)SDL_CreateThread(ThreadHandler, "SDL_Thread", this);
	}
}

void Thread::join()
{
	if(alive)
	{
		SDL_WaitThread((SDL_Thread*)thread, NULL);
		thread = NULL;
	}
}

void Thread::sleep(long millis)
{
	SDL_Delay(millis);
}

bool Thread::isAlive()
{
	return alive;
}