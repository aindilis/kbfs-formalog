start :-
	inotify_init(INotify,[]),
	inotify_add_watch(INotify,'/home/andrewdo',[]),
	inotify_read_event(INotify, Event, []).

%% access
%% 	File was accessed

%% attrib
%% 	File metadata changed

%% close_write
%% 	File opened for writing was closed.

%% close_nowrite
%% 	File or directory not opened for writing was closed.

%% create
%% 	File/directory created in watched directory.

%% delete
%% 	File/directory deleted from watched directory.

%% delete_self
%% 	Watched file/directory was itself deleted. The target is automatically removed from the watched targets.

%% modify
%% 	File was modified (e.g., write(2), truncate(2)).

%% move_self
%% 	Watched file/directory was itself moved. Unfortunately the interface doesn't tell us where the directory or file moved to. As a result, inotify_current_watch/2 indicates the old location and all reported events keep indicating the old location.

%% moved_from
%% 	Generated for the directory containing the old filename when a file is renamed.

%% moved_to
%% 	Generated for the directory containing the new filename when a file is renamed.

%% open
%% 	File or directory was opened.