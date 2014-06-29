
#include <pthread.h>

#pragma once

class Thread
{
	friend void* Thread_Handler(void*);
private:
	pthread_t thread;
	bool alive;
	
public:
	Thread();
	virtual ~Thread();
	
	virtual void run();
	virtual void finish();
	
	void start();
	void join();
	
	bool isAlive();
	
	static void sleep(unsigned long millis);
};