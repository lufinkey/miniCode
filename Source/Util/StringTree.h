
#include "String.h"
#include "SortedStringList.h"

#pragma once

class StringTree
{
private:
	SortedStringList branchNames;
	ArrayList<StringTree*> branches;
	SortedStringList members;
	
	bool duplicates;
	
public:
	StringTree();
	StringTree(bool duplicates);
	StringTree(const StringTree&tree);
	StringTree(const StringTree&tree, bool duplicates);
	~StringTree();
	
	StringTree& operator=(const StringTree& tree);
	
	bool addMember(const String&member);
	bool renameMember(const String&oldName, const String&newName);
	bool removeMember(const String&member);
	int hasMember(const String&member) const;
	ArrayList<String>& getMembers();
	const ArrayList<String>& getMembers() const;
	
	bool addBranch(const String&branch);
	bool addBranch(const String&branch, const StringTree&heirarchy);
	bool renameBranch(const String&oldName, const String&newName);
	bool removeBranch(const String&branch);
	int hasBranch(const String&branch) const;
	StringTree* getBranch(const String&branch);
	const StringTree* getBranch(const String&branch) const;
	ArrayList<String>& getBranchNames();
	const ArrayList<String>& getBranchNames() const;
	void merge(const StringTree&tree);
	void clear();
	
	ArrayList<String> getPaths();
};