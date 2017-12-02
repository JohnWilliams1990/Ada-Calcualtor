--John Williams
--105201054
--Principals of Programming
-- homework 3 ->Ada Calculator



with Ada.Text_IO; use Ada.Text_IO;
with ada.Characters; use ada.Characters;
with ada.Integer_Text_IO; use ada.Integer_Text_IO;
with ada.Float_Text_IO; use ada.Float_Text_IO;
with Unbound_Stack;

procedure Homework_3 is
   package Unbound_Character_Stack is new Unbound_Stack (Character);
   package unboundFloatStack is new Unbound_Stack (float);-- float;
   package unboundIntegerStack is new Unbound_Stack (Integer);-- int;

   use Unbound_Character_Stack;
   use unboundIntegerStack;
   use unboundFloatStack;

   Buffer : String (1..1000);		--character array for the input string from the file
   Last : Natural;		--natural number used for the length of the current string 
   number : Integer := 0;		--number used to reset the beginning index when we call the CaculateInteger() function 
   inStream: File_Type;
   recursionFlag: boolean := false;
   ParenthesisCounter: Integer := 0;
  
----------------------------------------------------------------------------------------------------
		--
		--Description: this function is used to calcutate an expression based on the input whick is of interger tyoe
   		--Input: Two integers and a character to represent the operation being attempted
   		--Output: an integer answer.  
   		--
      
    function answer(leftHand: in Integer;rightHand: in Integer;operator: in Character) return Integer is

      begin
         case operator is
            when '*' =>
               return leftHand*rightHand;
            when '/' =>
               return leftHand/rightHand;
            when '+' =>
               return leftHand+rightHand;
            when '-'=>
               return leftHand-rightHand;
             when others => -- error has already been signaled to user
            return 0;

            end case;

         end answer;
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------


		--
		--Description: this function is used to calcutate an expression based on the input which is of Float tyoe
   		--Input: Two Floating point numbers and a character to represent the operation being attempted
   		--Output: an Floating point answer.  
   		--
   function answerF(leftHand: in float ;rightHand: in float ;operator: in Character) return float is

      begin
         case operator is-- determine operator and execute calculation and then return calculation. 
            when '*' =>
               return leftHand*rightHand;
            when '/' =>
               return leftHand/rightHand;
            when '+' =>
               return leftHand+rightHand;
            when '-'=>
               return leftHand-rightHand;
             when others => -- error has already been signaled to user
            return 0.0;

            end case;

   end answerF;
----------------------------------------------------------------------------------------------------





      -- Description: function is designed to get the integer up till the next non numeric character
      -- it is designed to return that integer and then to update the index in the main function
      -- Input: the current index in the string, the number representing the last character in the index
      -- 
----------------------------------------------------------------------------------------------------
   function getInt(Index : in out Integer; Last  : in Integer) return Integer is

         number: Integer:= 0;-- number to be read in and returned
         newIndex: Integer := 0;-- tracking indext to be returned at completeion of function
      begin

          for i in Natural range Index..Last loop	-- traverse the entire string from the current postion
            if ((Character'Pos(Buffer(i)) - 48)>=0 and (Character'Pos(Buffer(i)) - 48)<=9) then	--if it is a number 

            Number:= number + Character'Pos(Buffer(i)) - 48;	--add it to the number

             if  i <last then-- if index is less than last
                    Number := Number*10;-- multiply the number by ten
                    end if;
            newIndex:=i;-- track the index to return
            else-- becuase of an off by one error at the end of a number, which is at then end of a string, we must divide the number by 10 for the final number

               number := number / 10;
               Index := i;-- track the index
               return number;-- return the number

               end if;


         end loop;

         if newIndex>0 then-- if it is a real number that return it and the index
            Index := newIndex+1;
            return number;
         else
            number := 0;-- else signal operator that it is nut a number
            Index := -1;--sentinal telling us that there is no first operand.
            return number;
            end if;

      end getInt;
----------------------------------------------------------------------------------------------------


   
      -- Description: function is designed to calculate integer expressions. it is designed to return that integer
      -- Input: the current index in the string, the number representing the last character in the index
   ----------------------------------------------------------------------------------------------------
function CalculateInterger(currentIndex : in Integer; Last  : in Integer; Buffer :in String ) return Integer is

   m : Integer :=currentIndex;-- inside index being used on the numbers
   operatorStack : Unbound_Character_Stack.Stack;	-- stack use for the operators
   operANDStack: unboundIntegerStack.Stack;	--stack used for the operands 
   
   number1: Integer:= 0;	-- placeholder for the return of a number form getInt
   Char: Character;	-- placeholder for the operator	--
   intRight,intLeft: Integer;	-- placeholder for removing from the stack
   ch : Character;	-- placeholder for the character
   doNextCalc : Boolean := false;-- boolean for the stack order as we parse operations

   begin
      ------------------------------------------------------------------------------------------------------------------------
     
      while (m<=Last)-- while there is still a string to read	-- 
        loop

         number1 := getInt(m, Last);	-- get a number

         if m = -1 then

            --raise Numeric_Error;
            Put_Line("Error unknown operator!!!!!");
            return 0;

         else

	-- place on stack
            Push (number1, onto => operANDStack ); -- because we have encountered an operator we can put the first operand on the stack
            number1 := 0;-- because we have encountered an operator
         end if;



	-- if there is a conflict on the stack and we need to do a calculation
         	if doNextCalc = true then

          	  doNextCalc := false;-- do the next available calculation and place on stack

           	 if not Is_Empty(operANDStack) then
            	   Pop(intRight,From => operANDStack );
           	 end if;

            	if not Is_Empty(operatorStack) then
             	  Pop(ch,From => operatorStack );
            	end if;

            	if not Is_Empty(operANDStack) then
             	  Pop(intLeft,From => operANDStack );
            	end if;

--            	put(intLeft);put(" ");Put(ch); put(" ");put(intRight,0);put(" = ");

            	-- push answer onto the stack
            	push(answer(intLeft,intRight,  ch),onto => operANDStack);


         	end if;



         -- place the operand on the stack -- since we encountered an operator
         if ((Buffer(m) = '*' or Buffer(m) = '/' or Buffer(m) = '-' or Buffer(m) = '+') and Is_Empty(operatorStack)) then
            Put("NO OPERATOR ON STACK -->");
            Push (Buffer(m), onto => operatorStack );


            m := m+1;	-- increment the index

            -- if there is alread an operand on the stack--> then we need to do a calculation.....
         elsif ((Buffer(m) = '*' or Buffer(m) = '/' or Buffer(m) = '-' or Buffer(m) = '+') and (not Is_Empty(operatorStack)))  then

            -- three possabilities

            Top(Char, From => operatorStack);

              -- if the lower operator has lower precedence
            	if ((Buffer(m) =  '*' or Buffer(m) = '/' )  and (Char = '+' or  Char = '-' ))then-- if the first operator has higher precedence
             	     Put_Line("LOW Precedence on bottom");

              	-- here we know that we cannot have more than two operators on the stack....
             	-- so we must calculate the new expression first
            	-- how to we know the size of the stack..... --> we can only see the top
                -- yet we need the next number to do this calculation ....

                -- place operator on stack
                -- write flage high meaning we have only the option to do the next calculation ... regardless of waht it is

               		Push (Buffer(m), onto => operatorStack );
               		doNextCalc := true;
            		m := m+1;

                -- if the lower operator has higher precedence
	        elsif ((Buffer(m) =  '+' or Buffer(m) ='-' )  and (Char = '*' or  Char ='/'))then
			Put_Line("HIGH Precedence on bottom");
                -- since lower precedence is on bottom---> calculate the lower expression and put result on stack
                -- then place the new operator on the stack with the (new number)-- comming from the string via the loop.

      		        if not Is_Empty(operANDStack) then
                          Pop(intRight,From => operANDStack );
         	        end if;
                        if not Is_Empty(operatorStack) then
                          Pop(ch,From => operatorStack );
                        end if;
                	if not Is_Empty(operANDStack) then
                  	  Pop(intLeft,From => operANDStack );
               		end if;

                	--put(intLeft);put(" ");Put(ch); put(" ");put(intRight,0);put(" = "); put(answer(intLeft,intRight,  ch),0);
 
                 	-- push answer onto the stack
                 	push(answer(intLeft,intRight,  ch),onto => operANDStack);

               		-- push new operator onto stack
            		Push (Buffer(m), onto => operatorStack );

              		m := m+1;

            	else -- by logic there are only three possabilities. if we reached this conclusion then both operators have the same precedence so now we operate left to right...

             	        Put_Line("Same Precedence");

                        -- WE MUST GO LEFT TO RIGHT KEEPING SIGN IN MIND FOR DIVISION AND SUBTRACTION

                        if not Is_Empty(operANDStack) then
                           Pop(intRight,From => operANDStack );
                        end if;

                        if not Is_Empty(operatorStack) then
                            Pop(ch,From => operatorStack );
                        end if;

                        if not Is_Empty(operANDStack) then
                            Pop(intLeft,From => operANDStack );
                        end if;

                        put(intLeft);put(" ");Put(ch); put(" ");put(intRight,0);put(" = "); put(answer(intLeft,intRight,  ch),0);
                        new_line;new_line;

                        -- push answer onto the stack
                        push(answer(intLeft,intRight,  ch),onto => operANDStack);



               		-- push operator onto stack
                        Push (Buffer(m), onto => operatorStack );

	                m := m+1;

            end if;

            -- catch erronious characters
         elsif (m <= Last) and (Buffer(m) /= '*' or Buffer(m) /= '/' or Buffer(m) /= '-' or Buffer(m) /= '+' or not ((Character'Pos(Buffer(m)) - 48)>=0 and (Character'Pos(Buffer(m)) - 48)<=9)) then
            raise Numeric_Error;
         end if;
   end loop;


      --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if  not Is_Empty(operatorStack) then

         declare	---experiment with local block of variables and code
            -- pull whatever is on the stack off and do the calculations--> then return this number
            ch:Character;
            intLeft: Integer;
            intRight: Integer;
         begin

         Pop(intRight,From => operANDStack );
         Pop(ch,From => operatorStack );
         Pop(intLeft,From => operANDStack );
           -- put(intLeft);put(" ");Put(ch); put(" ");put(intRight,0);put(" = "); put(answer(intLeft,intRight,  ch),0);
           --  new_line;new_line;


         return answer(intLeft,intRight,  ch);

         end;
      --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      else

            raise Numeric_Error;
         --Put_Line("ERROR--Not a valid expression");
      end if;



   exception
      when Numeric_Error =>

         Put_Line("Exception encounter with erronious input.");
         Put_Line("Please try again.");
      return 0;



      end CalculateInterger;

----------------------------------------------------------------------------------------------------

   
   
      -- Description: function is designed to get the Float up till the next non numeric character
      -- it is designed to return that flaot and then to update the index in the main function
      -- Input: the current index in the string, the number representing the last character in the index
      -- 
----------------------------------------------------------------------------------------------------   
-- forget about trying to limit the size of the number or precision. just return the number and the index. 
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
function getFloat(Index : in out Integer; Last  : in Integer) return Float is
      decimalBool : Boolean := false;
         number: Float:= 0.0;
      newIndex: Integer := 0;
      decimalIndex: Integer :=1;
      precision:integer  := 1;

   begin
      precision := 1;

      for i in Natural range Index..last loop


         if ((Character'Pos(Buffer(i)) - 48)>=0 and (Character'Pos(Buffer(i)) - 48)<=9)  then--and i /= last

--Put(Buffer(i));new_Line;
            	if decimalBool = false then
               Number:= number + float(Character'Pos(Buffer(i)) - 48);
                newIndex:=i;-- keep track of the index so that we can return it

               --if the next character is a number.........
               	  if ((Character'Pos(Buffer(i+1)) - 48)>=0 and (Character'Pos(Buffer(i+1)) - 48)<=9) and  Character(Buffer(i+1)) /= '.' and i /= last then--               	  if  i <stoppingIndex-1 and Character(Buffer(i+1)) /= '.' then   ---> removed the

                    Number := Number*10.0;
                    end if;


                elsif  decimalBool = true then
                  Number:= number + Float(Character'Pos(Buffer(i)) - 48)*(1.0/10.0)**(precision);
               		newIndex:= i;

                 		if i   <last then
                   	precision := precision + 1;
              	   	end if;

            	end if;

            elsif Character(Buffer(i)) = '.' then
            decimalBool := true;
         else

            newIndex := i;

            if (not ((Character'Pos(Buffer(i)) - 48)>=0 and (Character'Pos(Buffer(i)) - 48)<=9)) or i = last then

               Index := newIndex;-- dont need to increment by one because of the decimal point ...?

        	   return number;

               end if;

         end if;
      end loop;

          	   Index := newIndex+1;
        	   return number;


      end getFloat;




----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------















----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Description: function is designed to calculate Float expressions with parenthesis.
--it is designed touse recursion to implament a call to itself on specific conditions and to return thatfloating point numbers
-- Input: the current index in the string, the number representing the last character in the index
--OutPut: Returns the Floating point number based on the said calulations and operator 
----------------------------------------------------------------------------------------------------

function CalculateFloat(M : in out Integer; Last  : in Integer) return float is

   operatorStack : Unbound_Character_Stack.Stack;	-- stack used for the operators 
   operANDStack: unboundFloatStack.Stack;	--stack used for the operands of the expressions
   
   number1: float := 0.0;	--temp variable for the holing the return from specific functions 
   Char: Character; 	--temp char for comparisons 
   Right: Float := 0.0;	--temp variable for caluclations 
   Left: Float := 0.0;--temp variable for caluclations 
   ch : Character;--temp char for stack operations
   doNextCalc : Boolean := false;-- flag for clearing a claculation off of the stack
   operatorEncountered: Boolean := true;-- flag to see if we have encountered an operator
   endParenthesis :boolean := false;-- flag to see if we have encountered a end paren. 
      --need to make a Boolean variable that says that if we entered a recursion we must
      --also leave a recursion by seeing a ')' put this at end of return for the end of the function



   begin
      ------------------------------------------------------------------------------------------------------------------------

      while (m<=Last)-- while there are still cahracters to be read
        loop

         if  Buffer(m) = ' ' then-- if its a space then skip it
                m := m+1;-- increment the index
         end if;

               ---------------------------------------------------------------------------------------------------------------------
         if Buffer(m) = '(' then-- if it is an open parenthesis then begin recursion 

            -- if last thing encountered was a number
            if operatorEncountered = false  then --is a number next to the parenthesis i.e out front of one
            raise Numeric_Error;
              end if;

            if endParenthesis = true then--> are two parenthesis back to back )(
            raise Numeric_Error;
              end if;



            m := m+1;-- increment index
            ParenthesisCounter := ParenthesisCounter+1;

            left := CalculateFloat(m, Last);
            endParenthesis := true;-- by logic I return here from a recursive call. then I must have just passed a ')'
            m := m+1;-- increment index
            push(left,onto => operANDStack);

            if M>last then-- if the index is greater than last at this point then exit the loop and let the clean up portion handle the stack
               exit;
            end if;

         end if;
         if Buffer(m) = ')' then
-- calculate what is on the stack and return it.....
--three situations... must remove everything from stack....


            ParenthesisCounter := ParenthesisCounter-1;-- decrement the parenthesis counter

            if (ParenthesisCounter < 0)then -- by logic--> if there are negative parenthesis someones fingers slipped
               raise Numeric_Error;
            end if;

            if not (Is_Empty(operatorStack)) then
               while not Is_Empty(operatorStack)
               loop
                  if not Is_Empty(operANDStack) then
                     Pop(Right,From => operANDStack );
                  end if;

                  if not Is_Empty(operatorStack) then
                     Pop(ch,From => operatorStack );
                  end if;

                  if not Is_Empty(operANDStack) then
                     Pop(Left,From => operANDStack );
                     else
                  raise Numeric_Error;
                  end if;


            --put(Left,0,7,0);put(" ");Put(ch); put(" ");put(Right,0,7,0);put(" = "); put(answerf(Left,Right,  ch),0,7,0);
            --New_Line;New_Line;

                  push( answerf(Left,Right,  ch), onto => operANDStack);-- push the answer onto the stack

               end loop;

                  return answerf(Left,Right,  ch);---- push the answer onto the stack


           elsif (Is_Empty(operatorStack) and not Is_Empty(operANDStack)) then

               Pop(Right,From => operANDStack );

            return Right;


           end if;





         end if;
      ---------------------------------------------------------------------------------------------------------------------





         -- if it is a number at the current index then read it in as such
        if ((Character'Pos(Buffer(M)) - 48)>=0 and (Character'Pos(Buffer(M)) - 48)<=9) or (Buffer(M) = '.')  then


            if endParenthesis = true then
            raise Numeric_Error;
         end if;

            if operatorEncountered = true then
            operatorEncountered := false;
            number1 := getFloat(m, Last) ;
            Push (number1, onto => operANDStack ); -- because we have encountered an operator we can put the first operand on the stack
            number1 := 0.0;-- because we have encountered an operator
            else
               raise Numeric_Error;
                 end if;

         if (M>last) then
            exit;
            end if;

         end if;


--------------------------

-- must come after I read in a number
         	if doNextCalc = true then
            	--
          	  doNextCalc := false;

           	 if not Is_Empty(operANDStack) then
            	   Pop(Right,From => operANDStack );
           	 end if;

            	if not Is_Empty(operatorStack) then
             	  Pop(ch,From => operatorStack );
            	end if;

            	if not Is_Empty(operANDStack) then
             	  Pop(Left,From => operANDStack );
            	end if;

            	--put(Left,0,7,0);put(" ");Put(ch); put(" ");put(Right,0,7,0);put(" = "); put(answerf(Left,Right,  ch),0,7,0);

            	-- push answer onto the stack
            	push(answerf(Left,Right,  ch),onto => operANDStack);



         	end if;








        -- place the operand on the stack
      	if ((Buffer(m) = '*' or Buffer(m) = '/' or Buffer(m) = '-' or Buffer(m) = '+') and Is_Empty(operatorStack)) then
            operatorEncountered := true; -- signal that an operator has been encountered
            endParenthesis := false;-- signal that an operator has been encountered
            Push (Buffer(m), onto => operatorStack );		--put operator on stack
            m := m+1;		--increnment count


            -- if there is alread an operand on the stack--> then we need to do a calculation.....
         elsif ((Buffer(m) = '*' or Buffer(m) = '/' or Buffer(m) = '-' or Buffer(m) = '+') and (not Is_Empty(operatorStack)))  then
            -- three possabilities

            		--take a look at the operator on the stack
            Top(Char, From => operatorStack);
            operatorEncountered := true;
            endParenthesis := false;


              -- if the lower operator has lower precedence
            	if ((Buffer(m) =  '*' or Buffer(m) = '/' )  and (Char = '+' or  Char = '-' ))then-- if the first operator has higher precedence
              	-- here we know that we cannot have more than two operators on the stack....
             	-- so we must calculate the new expression first
            	-- how to we know the size of the stack..... --> we can only see the top
                -- yet we need the next number to do this calculation ....


                -- place operator on stack
                -- write flag high meaning we have only the option to do the next calculation ... regardless of waht it is

               		Push (Buffer(m), onto => operatorStack );
               		doNextCalc := true;
               --if M +1 <= last then


            		m := m+1;-- increment index


               --  end if;
                -- if the lower operator has higher precedence
	        elsif ((Buffer(m) =  '+' or Buffer(m) ='-' )  and (Char = '*' or  Char ='/'))then

                -- since lower precedence is on bottom---> calculate the lower expression and put result on stack
                -- then place the new operator on the stack with the (new number)-- comming from the string via the loop.



      		        if not Is_Empty(operANDStack) then
                  	Pop(Right,From => operANDStack );

         	        end if;
                        if not Is_Empty(operatorStack) then
                          Pop(ch,From => operatorStack );
                        end if;
                	if not Is_Empty(operANDStack) then
                  	  Pop(Left,From => operANDStack );
               		end if;
               		--put(Left,0,7,0);put(" ");Put(ch); put(" ");put(Right,0,7,0);put(" = "); put(answerf(Left,Right,  ch),0,7,0);New_Line;
--
                 	-- push answer onto the stack
                 	push(answerf(Left,Right,  ch),onto => operANDStack);
               		-- push new operator onto stack
            		Push (Buffer(m), onto => operatorStack );
              		m := m+1;-- increment index

            	else -- by logic there are only three possabilities. if we reached this conclusion then both operators have the same precedence so now we operate left to right...

                        -- WE MUST GO LEFT TO RIGHT KEEPING SIGN IN MIND FOR DIVISION AND SUBTRACTION

                        if not Is_Empty(operANDStack) then
                           Pop(Right,From => operANDStack );
                        end if;

                        if not Is_Empty(operatorStack) then
                            Pop(ch,From => operatorStack );
                        end if;

                        if not Is_Empty(operANDStack) then
                            Pop(Left,From => operANDStack );
                        end if;

             		--put(Left,0,7,0);put(" ");Put(ch); put(" ");put(Right,0,7,0);put(" = "); put(answerf(Left,Right,  ch),0,7,0);
                      --new_line;new_line;

                        -- push answer onto the stack
                        push(answerf(Left,Right,  ch),onto => operANDStack);
                        Push (Buffer(m), onto => operatorStack );
	                m := m+1;-- increment index

            end if;
         end if;
      end loop;


      
      
      -- clean up the recursion stacks
      -- if we dont have a parenthesis error and there is something on the operator stack--> resolve the
      -- remaining expressions or just return the answer
          if ParenthesisCounter = 0 and (not Is_Empty(operatorStack)) then 
	         while not Is_Empty(operatorStack)
 	             loop
   	         if not Is_Empty(operANDStack) then
    	           Pop(Right,From => operANDStack );
     	         end if;

        	if not Is_Empty(operatorStack) then
                Pop(ch,From => operatorStack );
            	end if;

            	if not Is_Empty(operANDStack) then
             	  Pop(Left,From => operANDStack );
            	end if;

            	--put(Left,0,7,0);put(" ");Put(ch); put(" ");put(Right,0,7,0);put(" = "); put(answerf(Left,Right,  ch),0,7,0);

                  push( answerf(Left,Right,  ch), onto => operANDStack);

            	end loop;
             	 return answerf(Left,Right,  ch);

           elsif ParenthesisCounter = 0 and (Is_Empty(operatorStack) and not Is_Empty(operANDStack)) then

               Pop(Right,From => operANDStack );
            return Right;

      elsif ParenthesisCounter /= 0 then

         --Put("Parenthesis error: ");put(ParenthesisCounter);New_Line;
            raise Numeric_Error;
         return 0.0;

           end if;



return 0.0;-- resolves a compiler issue




   exception
      when Numeric_Error =>

         if (ParenthesisCounter > 0) then
            ParenthesisCounter := ParenthesisCounter-1;-- this allows for us to bubble up the exception from each level of recursion and then handle it inside the main function
            raise;
         else
         Put(" ");
            raise;
            --return 0.0;
            end if;


      end CalculateFloat;




----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

begin-- Homework_3 procedure

   open(inStream, In_File, "testExpressions.txt" );-- open a text file and set it to input and give it the handle of inStream

  number:= 1;

     while not End_Of_File(inStream)-- while not at the end of the file
   loop
begin
      ParenthesisCounter := 0;-- reset the global variable
      last := 1;-- reset the string size;

      number:= 1; --reset initaila count  
      Get_Line(inStream,Buffer,last);-- get a line from the file

      for i in 1..last loop-- write the expression to the screen
     	Put(Buffer(i));
      end loop;
   
         Put(" = ");
-- get the answer or the exception and print it in a correct format
  Put(CalculateFloat(number, Last),0,5,3);New_Line; 

      Put_Line("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

 exception when Numeric_Error =>--- if a numeric error -- print it as such and disregard so as to continue the loop

      Put_Line("NOT A VALID EXPRESSION");
      Put_Line("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
end;

   end loop;




end Homework_3;
