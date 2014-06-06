
#include "SortedStringList.h"
#include "Console.h"

SortedStringList::SortedStringList()
{
	duplicates = false;
}

SortedStringList::SortedStringList(bool duplicates)
{
	this->duplicates = duplicates;
}

SortedStringList::SortedStringList(const SortedStringList&list)
{
	duplicates = list.duplicates;
	members = list.members;
}

SortedStringList::~SortedStringList()
{
	members.clear();
}

SortedStringList& SortedStringList::operator=(const SortedStringList& list)
{
	members.clear();
	duplicates = list.duplicates;
	members = list.members;
	
	return *this;
}

int SortedStringList::size() const
{
	return members.size();
}

int SortedStringList::add(const String&member)
{
	for(int i=0; i<members.size(); i++)
	{
		int result = member.compare(members.get(i));
		if(result == 1)
		{
			members.add(i, member);
			return i;
		}
		else if(result==0)
		{
			if(!duplicates)
			{
				return -1;
			}
			else if(i==(members.size()-1))
			{
				members.add(member);
			}
		}
		else if(result==-1)
		{
			if(i == (members.size()-1))
			{
				members.add(member);
				return (i+1);
			}
		}
		else
		{
			Console::WriteLine("Fatal Error in SortedStringList::add. String::compare(const String&) returned unknown value");
			throw std::exception();
		}
	}
	
	if(members.size()==0)
	{
		members.add(member);
		return 0;
	}
	
	Console::WriteLine("Fatal Error in SortedStringList::add");
	throw std::exception();
}

Vector2i SortedStringList::replace(const String&oldMember, const String&newMember)
{
	if(members.size()==0)
	{
		return Vector2i(-1,-1);
	}
	
	int oldIndex = -1;
	
	int cmpResult = newMember.compare(oldMember);
	
	if(cmpResult == 0)
	{
		for(int i=0; i<members.size(); i++)
		{
			if(members.get(i).equals(oldMember))
			{
				members.set(i, newMember);
				return Vector2i(i,i);
			}
		}
		return Vector2i(-1,-1);
	}
	else
	{
		int duplicateIndex = -1;
		int lastPushIndex = -1;
		
		for(int i=0; i<members.size(); i++)
		{
			if(members.get(i).equals(newMember))
			{
				if(duplicates)
				{
					if(duplicateIndex==-1)
					{
						duplicateIndex = i;
					}
				}
				else
				{
					return Vector2i(-1,-1);
				}
			}
			else if(newMember.compare(members.get(i))==-1)
			{
				lastPushIndex = i;
			}
			if(members.get(i).equals(oldMember))
			{
				oldIndex = i;
			}
		}
		
		if(oldIndex==-1)
		{
			return Vector2i(-1,-1);
		}
		else
		{
			members.remove(oldIndex);
			if(oldIndex<=duplicateIndex)
			{
				duplicateIndex--;
			}
			if(duplicates && duplicateIndex>-1)
			{
				members.add(duplicateIndex, newMember);
				return Vector2i(oldIndex, duplicateIndex);
			}
		}
		
		if(cmpResult == 1)
		{
			if(oldIndex == 0)
			{
				members.add(0, newMember);
				return Vector2i(oldIndex, 0);
			}
			else
			{
				for(int i=0; i<oldIndex; i++)
				{
					int result = newMember.compare(members.get(i));
					if(result==1)
					{
						members.add(i,newMember);
						return Vector2i(oldIndex, i);
					}
					else if(result==-1)
					{
						if(i==(oldIndex-1))
						{
							members.add(oldIndex,newMember);
							return Vector2i(oldIndex, oldIndex);
						}
					}
					else
					{
						if(duplicates)
						{
							members.add(i, newMember);
							return Vector2i(oldIndex, i);
						}
						else
						{
							// I already checked for duplicates above, so this should never happen
							Console::WriteLine("Fatal Error in SortedStringList::::replace, possibly due to multithreading");
							throw std::exception();
						}
					}
				}
			}
		}
		else if(cmpResult==-1)
		{
			if(oldIndex == members.size())
			{
				members.add(newMember);
				return Vector2i(oldIndex, oldIndex);
			}
			else
			{
				for(int i=oldIndex; i<members.size(); i++)
				{
					int result = newMember.compare(members.get(i));
					if(result==1)
					{
						members.add(i, newMember);
						return Vector2i(oldIndex, i);
					}
					else if(result==-1)
					{
						if(i==(members.size()-1))
						{
							members.add(newMember);
							return Vector2i(oldIndex, (i+1));
						}
					}
					else
					{
						if(duplicates)
						{
							members.add(i, newMember);
							return Vector2i(oldIndex, i);
						}
						else
						{
							// I already checked for duplicates above, so this should never happen
							Console::WriteLine("Fatal Error in SortedStringList::::replace, possibly due to multithreading");
							throw std::exception();
						}
					}
				}
			}
		}
		else
		{
			// I already checked for duplicates above, so this should never happen
			Console::WriteLine("Fatal Error in SortedStringList::replace, possibly due to multithreading");
			throw std::exception();
		}
	}
	return Vector2i(-1, -1);
}

int SortedStringList::get(const String&member) const
{
	for(int i=0; i<members.size(); i++)
	{
		if(member.equals(members.get(i)))
		{
			return i;
		}
	}
	
	return -1;
}

String& SortedStringList::get(int index)
{
	return members.get(index);
}

const String& SortedStringList::get(int index) const
{
	return members.get(index);
}

void SortedStringList::remove(int index)
{
	members.remove(index);
}

bool SortedStringList::remove(const String&member, int amount)
{
	int total = 0;
	for(int i=0; i<members.size(); i++)
	{
		if(member.equals(members.get(i)))
		{
			members.remove(i);
			if(!duplicates)
			{
				return true;
			}
			total++;
			if(amount>0)
			{
				if(total>=amount)
				{
					return true;
				}
			}
			i--;
		}
	}
	
	if(total>0)
	{
		return true;
	}
	return false;
}

void SortedStringList::clear()
{
	members.clear();
}

void SortedStringList::allowDuplicates(bool toggle)
{
	duplicates = toggle;
	if(!toggle && members.size()>1)
	{
		String prevMember = members.get(0);
		for(int i=1; i<members.size(); i++)
		{
			String currentMember = members.get(i);
			if(prevMember.equals(currentMember))
			{
				members.remove(i);
				i--;
			}
			else
			{
				prevMember = currentMember;
			}
		}
	}
}

ArrayList<String>& SortedStringList::getArrayList()
{
	return members;
}

const ArrayList<String>& SortedStringList::getArrayList() const
{
	return members;
}
