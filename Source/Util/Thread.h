
#pragma once

class Thread
{
	friend int ThreadHandler(void*);
private:
	void*thread;
	bool alive;
	
public:
	Thread();
	virtual ~Thread();
	
	virtual void run();
	virtual void finish();
	
	void start();
	void join();
	
	bool isAlive();
	
	static void sleep(long millis);
};