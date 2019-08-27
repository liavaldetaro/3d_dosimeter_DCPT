***************************
C# for dosimetry: General notes
***************************

Creating scripts that interact with the program Eclipse can lighten the burden when dealing with a large amount of data.

The following example shows a simple Console application::

    using System;

    namespace ConsoleApp1
    {
        class Program
        {
            static void Main(string[] args)
            {
                Console.WriteLine("Hello World! Enter a number");
                int h = Convert.ToInt32(Console.ReadLine());
                Console.WriteLine("The square of {0} number is " + h * h + "!", h);

                Console.Read();
            }
        }
    }

First the package System is activated. The symbol ; must terminate each line as is the case with other C languages. 
