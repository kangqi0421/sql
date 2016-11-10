CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED "OSCMD" AS
import java.io.*;
import java.util.*;

public class oscmd {

   // Execute OS command, capture stdout and errout and print it to Java
   // System.out and System.err
   // it returns the exit code of OS command
   // the executed command is run without any environmet set !!
   // e.g. instead of plain "ls", you must use "/usr/bin/ls"
   static public int runCommand(String cmd)
        throws IOException {

        int vSubResult;
        vSubResult = 0;

        // set up list to capture command output lines
        ArrayList list = new ArrayList();
        ArrayList elist = new ArrayList();

        // start command running
        Process proc = Runtime.getRuntime().exec(cmd);

        // get command's output stream and
        // put a buffered reader input stream on it
        InputStream istr = proc.getInputStream();
        BufferedReader br =
            new BufferedReader(new InputStreamReader(istr));

        // read output lines from command
        String str;
        while ((str = br.readLine()) != null)
            list.add(str);

        // get command's error stream and
        // put a buffered reader input stream on it
        InputStream estr = proc.getErrorStream();
        BufferedReader ebr =
            new BufferedReader(new InputStreamReader(estr));

        // read output lines from command
        while ((str = ebr.readLine()) != null)
            elist.add("ERR: " + str);

        // wait for command to terminate
        try {
            proc.waitFor();
        }
        catch (InterruptedException e) {
            System.err.println("ERR: process was interrupted");
            vSubResult = -1;
        }

        // check its exit value
        if (proc.exitValue() != 0) {
            System.err.println("ERR: exit value was non-zero (" + String.valueOf(proc.exitValue()) + ")");
            vSubResult = proc.exitValue();
        }

        // close stream
        ebr.close();
        br.close();

        // read all result strings into variable outlist
        String outlist1[] = (String[])list.toArray(new String[0]);
        String outlist2[] = (String[])elist.toArray(new String[0]);

        // display the output
        for (int i = 0; i < outlist1.length; i++)
            System.out.println(outlist1[i]);
        for (int i = 0; i < outlist2.length; i++)
            System.err.println(outlist2[i]);

        return vSubResult;
   }
   
   // entry point for PL/SQL to runCommand
   public static int plrunCommand(String args[]) throws IOException {
        try {
            int vResult;

            // run the given command
            vResult = runCommand(args[0]);

            // return 0 on success, 1 on failure
            return vResult; 
        }
        catch (IOException e) {
            System.err.println(e);
            return -2; 
        }
   }
}
/
