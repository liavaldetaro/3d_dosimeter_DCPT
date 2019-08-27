***************************
C# for dosimetry: General notes
***************************

Creating scripts that interact with the program Eclipse can lighten the burden when dealing with a large amount of data.

The following example shows a simple Console application written in C#::

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
Secondly the namespace ConsoleApp1 defines the name of the program, which has the class Program with the main method which takes a string as an argument. The user is prompted to type in a number, which is converted to a type Int32. In the end {0} then refers to the variable h, which is squared. Console.Read(); keeps the window from closing.
