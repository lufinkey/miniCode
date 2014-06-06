
#ifndef _SDL_p2p_h
#define _SDL_p2p_h

#include "SDL_video.h"

#include "begin_code.h"
/* Set up for C function definitions, even when using C++ */
#ifdef __cplusplus
extern "C"
{
#endif
	
	typedef enum
	{
		SDL_P2P_PEERCONNECTED = 0,
		SDL_P2P_PEERDISCONNECTED = 1,
		SDL_P2P_PEERREQUESTEDCONNECTION = 2,
		SDL_P2P_PICKERDIDCANCEL = 3,
		SDL_P2P_RECIEVEDDATA = 4
	} SDL_P2P_EventType;
	
	struct SDL_P2P_PeerInfo
	{
		char*peerID;
		char*peerDisplayName;
	};
	
	struct SDL_P2P_DataInfo
	{
		void*data;
		unsigned int size;
	};
	
	typedef struct
	{
		SDL_P2P_EventType type;
		SDL_Window*window;
		struct SDL_P2P_PeerInfo peer;
		struct SDL_P2P_DataInfo data;
	} SDL_P2P_Event;
	
	typedef void (*SDL_P2P_EventHandler)(SDL_P2P_Event*);
	
	typedef enum
	{
		SDL_P2P_SENDDATA_RELIABLE,
		SDL_P2P_SENDDATA_UNRELIABLE
	} SDL_P2P_SendDataMode;
	
	extern DECLSPEC void SDLCALL SDL_P2P_setEventHandler(SDL_P2P_EventHandler callback);
	
	extern DECLSPEC void SDLCALL SDL_P2P_searchForPeersBluetooth(SDL_Window*parent, const char*sessionID);
	
	extern DECLSPEC SDL_bool SDLCALL SDL_P2P_isConnected(SDL_Window*parent);
	extern DECLSPEC SDL_bool SDLCALL SDL_P2P_isConnectedToPeer(SDL_Window*parent, const char*peerID);
	
	extern DECLSPEC SDL_bool SDLCALL SDL_P2P_acceptConnectionRequest(SDL_Window*parent, const char*peerID);
	extern DECLSPEC void SDLCALL SDL_P2P_denyConnectionRequest(SDL_Window*parent, const char*peerID);
	
	extern DECLSPEC void SDLCALL SDL_P2P_getPeerDisplayName(SDL_Window*parent, const char*peerID, char*dispName);
	extern DECLSPEC void SDLCALL SDL_P2P_getSelfDisplayName(SDL_Window*parent, char*dispName);
	extern DECLSPEC void SDLCALL SDL_P2P_getSelfID(SDL_Window*parent, char*selfID);
	extern DECLSPEC void SDLCALL SDL_P2P_getSessionID(SDL_Window*parent, char*sessionID);
	
	extern DECLSPEC void SDLCALL SDL_P2P_sendData(SDL_Window*parent, void*data, unsigned int size, SDL_P2P_SendDataMode mode);
	extern DECLSPEC void SDLCALL SDL_P2P_sendDataToPeers(SDL_Window*parent, char**peers, unsigned int numPeers, void*data, unsigned int size, SDL_P2P_SendDataMode mode);
	
	extern DECLSPEC void SDLCALL SDL_P2P_disconnectPeer(SDL_Window*parent, const char*peerID);
	extern DECLSPEC void SDLCALL SDL_P2P_endSession(SDL_Window*parent);
	
/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif
#include "close_code.h"

#endif /* _SDL_p2p_h */