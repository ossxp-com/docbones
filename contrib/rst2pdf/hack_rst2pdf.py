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
 
import sys
import os
import re
import getopt
from subprocess import Popen, PIPE, STDOUT

SOFTWARE_NAME = "rst2pdf"
HACK_VERSION = 1

class SoftwareNotInstallError(Exception):
    """Have not installed needed software."""

class HackFailedError(Exception):
    """Hack failed."""

class Hack(object):

    def __init__(self):
        # test software installed location
        # import pkg_resources and delete it latter, or warning raised.
        import pkg_resources
        import rst2pdf
        if rst2pdf.__file__.endswith(".pyc"): 
            self.upstream_root = os.path.dirname( os.path.realpath( rst2pdf.__file__[0:-1] ) )
        else:
            self.upstream_root = os.path.dirname( os.path.realpath( rst2pdf.__file__ ) )
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
            raise SoftwareNotInstallError(SOFTWARE_NAME + " not installed.")

        pattern = re.compile("^(.*)\s+\(ossxp\s+(.*)\)")
        m = pattern.search(output)
        if m:
            self.upstream_version = m.group(1).strip()
            self.hack_version = int(m.group(2).strip())
        else:
            self.upstream_version = output.strip()
            self.hack_version = 0


    def upgrade(self, dryrun=False):
        assert self.hack_version <= HACK_VERSION

        # up-to-date
        if self.hack_version == HACK_VERSION:
            return

        elif self.hack_version == 0:
            # Hack against the latest patch...
            self.hack_latest( dryrun=dryrun )

        elif self.hack_version < 2:
            # Unhack previous patch...
            self.unhack_1( dryrun=dryrun )

            # Hack against the latest patch...
            self.hack_latest( dryrun=dryrun )


    def reverse(self, dryrun=False):
        assert self.hack_version <= HACK_VERSION

        # non-patch
        if self.hack_version == 0:
            return

        elif self.hack_version == 1:
            # Hack against the latest patch...
            self.unhack_1( dryrun=dryrun )


    def hack_1(self, sudo=False, reverse=False, dryrun=False):
        self.hack_latest(sudo=sudo, reverse=reverse, dryrun=dryrun)


    def unhack_1(self, sudo=False, dryrun=False):
        self.hack_1(sudo=sudo, reverse=True, dryrun=dryrun)


    def hack_latest(self, sudo=False, reverse=False, dryrun=False):
      
        if self.upstream_version == "0.14.2":
            patchfile = os.path.join( self.patch_root, "0.14", "1.patch" )
        else:
            patchfile = os.path.join( self.patch_root, "0.14", "1.patch" )

        args = [ "patch", "-d", self.upstream_root, "-p2" ]
        if sudo:
            args.insert(0, "sudo")

        if reverse:
            args.append( "-R" )

        cmdline = "%s --dry-run < %s" % (" ".join(args), patchfile)
        proc = Popen(cmdline, stdout=PIPE, stderr=STDOUT, shell=True)
        output = proc.stdout.read().rstrip()
        proc.wait()
        if proc.returncode != 0:
            raise HackFailedError( "Hack failed against upstream version %s, with %s" % ( self.upstream_version, patchfile ) )

        if dryrun:
            return

        cmdline = "%s < %s" % (" ".join(args), patchfile)
        proc = Popen(cmdline, stdout=PIPE, stderr=STDOUT, shell=True)
        output = proc.stdout.read().rstrip()
        proc.wait()
        if proc.returncode != 0:
            if not sudo:
                if "Operation not permitted" in output or "Permission denied" in output:
                    print "Permission denied, try to patch using sudo..."
                    self.hack_latest(sudo=True, reverse=reverse)
            else:
                raise HackFailedError( "Hack failed against upstream version %s, with %s" % ( self.upstream_version, patchfile ) )


    def unhack_latest(self, sudo=False, dryrun=False):
        self.hack_latest(sudo=sudo, reverse=True, dryrun=dryrun)


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

    
    if not cmd:
        return usage()

    # hack instance
    hack = Hack()

    if cmd == "test":
        print "%s version: %s" % (SOFTWARE_NAME, hack.upstream_version)

        if hack.hack_version == HACK_VERSION:
            print "ossxp hack version %s is uptodate." % HACK_VERSION

        elif hack.hack_version == 0:
            print "not hack yet."
            print "hackinging in dry-run mode...\t",
            try:
                hack.upgrade( dryrun=True )
            except HackFailedError:
                print "FAILED!"
            else:
                print "OK"

        elif hack.hack_version < HACK_VERSION:
            print "ossxp version %s is OUT-OF-DATE, new version: %s" % (
                self.hack_version,
                HACK_VERSION,
                )
            print "hackinging in dry-run mode...\t",
            try:
                hack.upgrade( dryrun=True )
            except HackFailedError:
                print "FAILED!"
            else:
                print "OK"
                
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
