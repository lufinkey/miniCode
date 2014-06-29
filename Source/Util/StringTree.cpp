
#include "StringTree.h"

StringTree::StringTree()
{
	duplicates = false;
}

StringTree::StringTree(bool duplicates)
{
	this->duplicates = duplicates;
}

StringTree::StringTree(const StringTree&tree)
{
	duplicates = tree.duplicates;
	branchNames = tree.branchNames;
	members = tree.members;
	for(int i=0; i<tree.branches.size(); i++)
	{
		branches.add(new StringTree(*tree.branches.get(i)));
	}
}

StringTree::StringTree(const StringTree&tree, bool duplicates)
{
	this->duplicates = duplicates;
	branchNames = tree.branchNames;
	members = tree.members;
	for(int i=0; i<tree.branches.size(); i++)
	{
		branches.add(new StringTree(*tree.branches.get(i), duplicates));
	}
}

StringTree::~StringTree()
{
	for(int i=0; i<branches.size(); i++)
	{
		delete branches.get(i);
	}
	branches.clear();
	branchNames.clear();
	members.clear();
}

StringTree& StringTree::operator=(const StringTree&tree)
{
	branchNames.clear();
	members.clear();
	for(int i=0; i<branches.size(); i++)
	{
		delete branches.get(i);
	}
	branches.clear();
	
	branchNames = tree.branchNames;
	members = tree.members;
	for(int i=0; i<tree.branches.size(); i++)
	{
		branches.add(new StringTree(*tree.branches.get(i)));
	}
	
	return *this;
}

//Members

bool StringTree::addMember(const String&member)
{
	if(!duplicates)
	{
		for(int i=0; i<branchNames.size(); i++)
		{
			if(member.equals(branchNames.get(i)))
			{
				return false;
			}
		}
	}
	int result = members.add(member);
	if(result==-1)
	{
		return false;
	}
	return true;
}

bool StringTree::renameMember(const String&oldName, const String&newName)
{
	if(!duplicates)
	{
		for(int i=0; i<branchNames.size(); i++)
		{
			if(newName.equals(branchNames.get(i)))
			{
				return false;
			}
		}
	}
	Vector2i result = members.replace(oldName, newName);
	if(result.x == -1)
	{
		return false;
	}
	return true;
}

//returns -1 if false, or index if true
int StringTree::hasMember(const String&member) const
{
	return members.get(member);
}

bool StringTree::removeMember(const String&member)
{
	return members.remove(member);
}

ArrayList<String>& StringTree::getMembers()
{
	return members.getArrayList();
}

const ArrayList<String>& StringTree::getMembers() const
{
	return members.getArrayList();
}



//Branches

bool StringTree::addBranch(const String&branch)
{
	if(!duplicates)
	{
		for(int i=0; i<members.size(); i++)
		{
			if(branch.equals(members.get(i)))
			{
				return false;
			}
		}
	}
	int result = branchNames.add(branch);
	if(result==-1)
	{
		return false;
	}
	branches.add(result, new StringTree(duplicates));
	return true;
}

bool StringTree::addBranch(const String&branch, const StringTree&heirarchy)
{
	if(!duplicates)
	{
		for(int i=0; i<members.size(); i++)
		{
			if(branch.equals(members.get(i)))
			{
				return false;
			}
		}
	}
	int result = branchNames.add(branch);
	if(result==-1)
	{
		return false;
	}
	branches.add(result, new StringTree(heirarchy, duplicates));
	return true;
}

bool StringTree::renameBranch(const String&oldName, const String&newName)
{
	if(!duplicates)
	{
		for(int i=0; i<members.size(); i++)
		{
			if(newName.equals(members.get(i)))
			{
				return false;
			}
		}
	}
	Vector2i result = branchNames.replace(oldName, newName);
	if(result.x==-1)
	{
		return false;
	}
	StringTree*tree = branches.get(result.x);
	branches.remove(result.x);
	branches.add(result.y, tree);
	return true;
}

bool StringTree::removeBranch(const String&branch)
{
	int result = branchNames.get(branch);
	branchNames.remove(branch);
	if(result==-1)
	{
		return false;
	}
	delete branches.get(result);
	branches.remove(result);
	return true;
}

//returns -1 if false, index if true
int StringTree::hasBranch(const String&branch) const
{
	return branchNames.get(branch);
}

StringTree* StringTree::getBranch(const String&branch)
{
	if(branch.length()==0 || branch.equals("/"))
	{
		return this;
	}
	
	int slashIndex = -1;
	for(int i=0; i<branch.length(); i++)
	{
		char c = branch.charAt(i);
		if(c=='/' && i!=0)
		{
			slashIndex = i;
			i = branch.length();
		}
	}
	if(slashIndex!=-1)
	{
		String subBranch;
		if(branch.charAt(0)=='/')
		{
			subBranch = branch.substring(1,slashIndex);
		}
		else
		{
			subBranch = branch.substring(0,slashIndex);
		}
		
		int result = branchNames.get(subBranch);
		if(result==-1)
		{
			return NULL;
		}
		StringTree*branchTree = branches.get(result);
		if(slashIndex==(branch.length()-1))
		{
			return branchTree;
		}
		return branchTree->getBranch(branch.substring(slashIndex+1));
	}
	else
	{
		String branchName;
		if(branch.charAt(0)=='/')
		{
			branchName = branch.substring(1);
		}
		else
		{
			branchName = branch;
		}
		int result = branchNames.get(branchName);
		if(result==-1)
		{
			return NULL;
		}
		return branches.get(result);
	}
}

const StringTree* StringTree::getBranch(const String&branch) const
{
	if(branch.length()==0 || branch.equals("/"))
	{
		return this;
	}
	
	int slashIndex = -1;
	for(int i=0; i<branch.length(); i++)
	{
		char c = branch.charAt(i);
		if(c=='/' && i!=0)
		{
			slashIndex = i;
			i = branch.length();
		}
	}
	if(slashIndex!=-1)
	{
		String subBranch;
		if(branch.charAt(0)=='/')
		{
			subBranch = branch.substring(1,slashIndex);
		}
		else
		{
			subBranch = branch.substring(0,slashIndex);
		}
		
		int result = branchNames.get(subBranch);
		if(result==-1)
		{
			return NULL;
		}
		StringTree*branchTree = branches.get(result);
		if(slashIndex==(branch.length()-1))
		{
			return branchTree;
		}
		return branchTree->getBranch(branch.substring(slashIndex+1));
	}
	else
	{
		String branchName;
		if(branch.charAt(0)=='/')
		{
			branchName = branch.substring(1);
		}
		else
		{
			branchName = branch;
		}
		int result = branchNames.get(branchName);
		if(result==-1)
		{
			return NULL;
		}
		return branches.get(result);
	}
}

ArrayList<String>& StringTree::getBranchNames()
{
	return branchNames.getArrayList();
}

const ArrayList<String>& StringTree::getBranchNames() const
{
	return branchNames.getArrayList();
}

void StringTree::merge(const StringTree& tree)
{
	const ArrayList<String>& treeMembers = tree.getMembers();
	for(int i=0; i<treeMembers.size(); i++)
	{
		addMember(treeMembers.get(i));
	}
	
	const ArrayList<String>& treeBranchNames = tree.getBranchNames();
	for(int i=0; i<treeBranchNames.size(); i++)
	{
		const String& treeBranchName = treeBranchNames.get(i);
		int branchIndex = hasBranch(treeBranchName);
		if(branchIndex!=-1)
		{
			branches.get(branchIndex)->merge(*tree.branches.get(i));
		}
		else
		{
			addBranch(treeBranchName, *tree.branches.get(i));
		}
	}
}

void StringTree::clear()
{
	for(int i=0; i<branches.size(); i++)
	{
		delete branches.get(i);
	}
	branches.clear();
	branchNames.clear();
	members.clear();
}

ArrayList<String> StringTree::getPaths()
{
	ArrayList<String> paths;
	
	for(int i=0; i<members.size(); i++)
	{
		paths.add(members.get(i));
	}
	
	for(int i=0; i<branches.size(); i++)
	{
		String& branchName = branchNames.get(i);
		ArrayList<String> branchPaths = branches.get(i)->getPaths();
		for(int j=0; j<branchPaths.size(); j++)
		{
			paths.add(branchName + '/' + branchPaths.get(j));
		}
	}
	
	return paths;
}



