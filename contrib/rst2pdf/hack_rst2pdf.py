#!/usr/bin/python

'''Hack rst2pdf

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

_NAME_          = "rst2pdf"
_HACK_VERSION_  = 2
_PATCHES_       = {
                    "rst2pdf" : {
                        "default"   : [ "%(root)s", "0.14", "%(version)d", "rst2pdf.patch" ],
                        "0.14.2"    : [ "%(root)s", "0.14", "%(version)d", "rst2pdf.patch" ],
                        },

                    "reportlab" : {
                        "default"   : [ "%(root)s", "0.14", "%(version)d", "reportlab.patch" ],
                        "0.14.2"    : [ "%(root)s", "0.14", "%(version)d", "reportlab.patch" ],
                        },
                  }

import sys
import os
import re
import getopt
from subprocess import Popen, PIPE, STDOUT

class SoftwareNotInstallError(Exception):
    """Have not installed needed software."""

class HackFailedError(Exception):
    """Hack failed."""

class Hack(object):

    def __init__(self):
        # test software installed location
        # import pkg_resources and delete it latter, or warning raised.
        self.upstream_root = {}

        import pkg_resources
        import rst2pdf
        import reportlab
        if rst2pdf.__file__.endswith(".pyc"): 
            self.upstream_root["rst2pdf"] = os.path.dirname( os.path.realpath( rst2pdf.__file__[0:-1] ) )
        else:
            self.upstream_root["rst2pdf"] = os.path.dirname( os.path.realpath( rst2pdf.__file__ ) )
        if reportlab.__file__.endswith(".pyc"): 
            self.upstream_root["reportlab"] = os.path.dirname( os.path.realpath( reportlab.__file__[0:-1] ) )
        else:
            self.upstream_root["reportlab"] = os.path.dirname( os.path.realpath( reportlab.__file__ ) )
        del pkg_resources
        del rst2pdf

        # patch file location
        self.patch_root = os.path.join( os.path.dirname(os.path.realpath(__file__)), "patch" )
 
        # test software version and hack version
        args = [ "rst2pdf", "--version" ]
        proc = Popen(args, stdout=PIPE, stderr=STDOUT)
        output = proc.stdout.read().strip()
        proc.wait()
        if proc.returncode != 0:
            raise SoftwareNotInstallError(_NAME_ + " not installed.")

        pattern = re.compile("^(.*)\s+\(ossxp\s+(.*)\)")
        m = pattern.search(output)
        if m:
            self.upstream_version = m.group(1).strip()
            self.hack_version = int(m.group(2).strip())
        else:
            self.upstream_version = output.strip()
            self.hack_version = 0


    def upgrade(self, dryrun=False):
        assert self.hack_version <= _HACK_VERSION_

        # up-to-date
        if self.hack_version == _HACK_VERSION_:
            return

        elif self.hack_version == 0:
            # Hack against the latest patch...
            self.hack_latest( dryrun=dryrun )

        else:
            # Unhack previous patch...
            fn_name = "unhack_%d" % self.hack_version
            try:
                fn = getattr(self, fn_name)
                fn( dryrun=dryrun )
            except AttributeError:
                self.reverse( dryrun=dryrun )

            # Hack against the latest patch...
            self.hack_latest( dryrun=dryrun )


    def reverse(self, dryrun=False):
        assert self.hack_version <= _HACK_VERSION_

        # non-patch
        if self.hack_version == 0:
            return

        # Hack against the latest patch...
        self.hack_latest( reverse=True, dryrun=dryrun, version=self.hack_version )


    # obsolete, for reference only.
    def unhack_1(self, dryrun=False):
        self.hack_latest( reverse=True, dryrun=dryrun, version=1 )


    def hack_latest(self, reverse=False, dryrun=False, version=_HACK_VERSION_):
        patches = {}
        for key in _PATCHES_.keys():
            dirs = _PATCHES_[ key ].get( self.upstream_version, _PATCHES_[ key ][ "default" ] )
            patches[key] = os.path.join( *[ k % {
                                                'root':self.patch_root,
                                                'version':version,
                                                } for k in dirs ] )
            if not os.path.exists( patches[ key ] ):
                raise HackFailedError( "Patch file not found: %s" % patches[key] )

        #"-d", self.upstream_root, 
        args = [ "patch", "-p2" ]

        if reverse:
            args.append( "-R" )

        # [ "reportlab", "rst2pdf" ]
        for key in self.upstream_root.keys():
            cmdline = "%s -d %s --dry-run < %s" % (" ".join(args), 
                                                 self.upstream_root[key],
                                                 patches[key])
            proc = Popen(cmdline, stdout=PIPE, stderr=STDOUT, shell=True)
            output = proc.stdout.read().rstrip()
            proc.wait()
            if proc.returncode != 0:
                raise HackFailedError( "Hack failed against upstream version %s!\n\tAgainst   : %s\n\tpatch file: %s\n\tcmdline   :%s" % ( self.upstream_version, self.upstream_root[key], patches[key], cmdline ) )

        if dryrun:
            return

        # [ "reportlab", "rst2pdf" ]
        for key in self.upstream_root.keys():
            cmdline = "%s -d %s < %s" % (" ".join(args), 
                                         self.upstream_root[key],
                                         patches[key])
            print "%s '%s' (ver %d) ...\t" % (reverse and "Un-patching" or "Patching", key, version),
            proc = Popen(cmdline, stdout=PIPE, stderr=STDOUT, shell=True)
            output = proc.stdout.read().rstrip()
            proc.wait()
            if proc.returncode != 0:
                if "Operation not permitted" in output or "Permission denied" in output:
                    print "\n\t*** No enough permissions, try to use sudo. You may ask for PASSWORD. ***"
                    print "\t%s '%s' (ver %d) with sudo...\t" % (reverse and "Un-patching" or "Patching", key, version),
                    cmdline = "sudo "+cmdline
                    proc = Popen(cmdline, stdout=PIPE, stderr=STDOUT, shell=True)
                    output = proc.stdout.read().rstrip()
                    proc.wait()
            if proc.returncode == 0:
                print "OK"
            else:
                print "FAILED!"
                raise HackFailedError( "Hack failed against upstream version %s!\n\tAgainst   : %s\n\tpatch file: %s\n\tcmdline   :%s" % ( self.upstream_version, self.upstream_root[key], patches[key], cmdline ) )



def usage(code=0, msg=''):
    if code:
        fd = sys.stderr
    else:
        fd = sys.stdout
    print >> fd, __doc__ % { 'program': os.path.basename(sys.argv[0]) }
    if msg:
        print >> fd, msg
    return code


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]

    try:
        opts, args = getopt.getopt( 
                argv, "hprt", 
                ["help", "patch", "reverse", "test", "check"])

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
        elif opt in ("--check"):
            cmd = "check"

    
    if not cmd:
        return usage()

    # hack instance
    hack = Hack()

    if cmd == "check":
        if hack.hack_version == _HACK_VERSION_:
            return 0
        else:
            return 1

    elif cmd == "test":
        print "%s version: %s" % (_NAME_, hack.upstream_version)

        if hack.hack_version == _HACK_VERSION_:
            print "ossxp hack (ver %d) is uptodate." % _HACK_VERSION_
            print "\ntest only: unpatch in dry-run mode...\t",
            try:
                hack.reverse( dryrun=True )
            except HackFailedError:
                print "FAILED!"
            else:
                print "OK"


        elif hack.hack_version == 0:
            print "not hack yet."
            print "\ntest only: hackinging in dry-run mode...\t",
            try:
                hack.upgrade( dryrun=True )
            except HackFailedError:
                print "FAILED!"
            else:
                print "OK"

        elif hack.hack_version < _HACK_VERSION_:
            print "ossxp version %s is OUT-OF-DATE, new version: %s" % (
                hack.hack_version,
                _HACK_VERSION_,
                )
            print "\ntest only: reverse old patch in dry-run mode...\t",
            try:
                hack.reverse ( dryrun=True )
            except HackFailedError:
                print "FAILED!"
            else:
                print "OK"

        print ""
                
    elif cmd == "patch":
        hack.upgrade()

    elif cmd == "reverse":
        hack.reverse()

    else:
        return usage(1, "unknown cmd: " + cmd)

    return 0


if __name__ == "__main__":
    sys.exit(main())

# vim: et ts=4 sw=4
