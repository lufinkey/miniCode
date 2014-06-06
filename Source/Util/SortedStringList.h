
#include "ArrayList.h"
#include "String.h"
#include "Vector2.h"

#pragma once

class SortedStringList
{
private:
	ArrayList<String> members;
	bool duplicates;
	
public:
	SortedStringList();
	SortedStringList(bool duplicates);
	SortedStringList(const SortedStringList&list);
	~SortedStringList();
	
	SortedStringList& operator=(const SortedStringList& list);
	
	int size() const;
	int add(const String&member);
	Vector2i replace(const String&oldMember, const String&newMember);
	int get(const String&member) const;
	String&get(int index);
	const String&get(int index) const;
	void remove(int index);
	bool remove(const String&member, int amount = 1);
	void clear();
	
	void allowDuplicates(bool toggle);
	
	ArrayList<String>&getArrayList();
	const ArrayList<String>&getArrayList() const;
};
