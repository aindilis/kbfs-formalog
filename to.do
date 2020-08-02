(hg clone http://aryx.kicks-ass.org/~pad/hg/hgwebdir.cgi/c-lfs  lfs-src
 hg clone http://aryx.kicks-ass.org/~pad/hg/hgwebdir.cgi/c-commons  commons
 mv commons lfs-src/)

(exactly model symlinks)

(need to incorporate temporal semantics, since for instance the
 same filename can at differing times be two different either
 versions (i.e. one a previous versino of the other), two
 different derivatives of the same common ancestor file, or two
 different files altogether, etc)

