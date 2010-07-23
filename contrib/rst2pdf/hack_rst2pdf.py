#!/usr/bin/python

'''Hack docutils

Usage: %(program)s [options]

Options:

    -h|--help
            Print this message and exit.

    -p|--patch
            Patching

    -r|--reverse
            Unpatching

    -t|--test
            Test whether already hacked.
'''
 
import sys
import os
import getopt
from subprocess import Popen, PIPE, STDOUT

def usage(code=0, msg=''):
    if code:
        fd = sys.stderr
    else:
        fd = sys.stdout
    print >> fd, __doc__ % { 'program': os.path.basename(sys.argv[0]) }
    if msg:
        print >> fd, msg
    return code

def is_hacked():
    try:
        from docutils.writers.html4css1 import Writer
    except ImportError:
        print "Error : You have not install python docutils ?!"
        sys.exit(1)

    try:
        if 'javascript' in Writer.visitor_attributes:
            return True
        else:
            return False
    except AttributeError:
        print "Error : Python docutils too old or too new, unsupport version!"
        sys.exit(1)

def do_hacks(sudo=False, reverse=False):
    import docutils
    if docutils.__file__.endswith(".pyc"): 
        docutils_location = os.path.realpath( docutils.__file__[0:-1] )
    else:
        docutils_location = os.path.realpath( docutils.__file__ )
    docutils_location = os.path.dirname( docutils_location )
    patchfile = os.path.join( os.path.dirname(os.path.realpath(__file__)),
                              "patch.txt" )
    
    command = "patch"
    if sudo:
        command = "sudo " + command

    options = "-p2"
    if reverse:
        options = options + " -R"

    cmdline = "%s %s -d %s < %s" % (command, options, docutils_location, patchfile)

    proc = Popen(cmdline, stdout=PIPE, stderr=STDOUT, shell=True)
    output = proc.stdout.read().rstrip()
    proc.wait()
    if proc.returncode != 0:
        if not sudo:
            print ""
            if "Operation not permitted" in output or "Permission denied" in output:
                print "Permission denied, try to patch using sudo..."
                do_hacks(sudo=True, reverse=reverse)
                sys.exit(0)

        print ""
        print "Hack failed!"
        print output
        print ""
        print "Patch by hands uisng the following command:"
        print " "*4 + "$",
        print cmdline
        sys.exit(1)


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]

    try:
        opts, args = getopt.getopt( 
                argv, "hprt", 
                ["help", "patch", "reverse", "test"])
    except getopt.error, msg:
        return usage(1, msg)

    cmd = None

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            return usage()
        elif opt in ("-r", "--reverse"):
            cmd = "reverse"
        elif opt in ("-p", "--patch"):
            cmd = "patch"
        elif opt in ("-t", "--test"):
            cmd = "test"

    hacked = is_hacked()
    if not cmd:
        return usage()
    elif cmd == "test":
        if hacked:
            return 0
        else:
            print "Un-hacked!"
            return 1
    elif cmd == "patch":
        if not hacked:
            print "Begin hacking...",
            do_hacks()
            print "Hacked."
        else:
            print "Already hacked."
        return 0
    elif cmd == "reverse":
        if hacked:
            print "Reverse hack...",
            do_hacks(reverse=True)
            print "Reversed."
        else:
            print "Already reversed."
        return 0
    else:
        return usage(1, "unknown cmd: " + cmd)

    return 0


if __name__ == "__main__":
    sys.exit(main())

# vim: et ts=4 sw=4
