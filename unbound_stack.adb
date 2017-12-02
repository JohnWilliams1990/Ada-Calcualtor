--unbound_stack.adb
package body Unbound_Stack is
   type Cell is record
      Item : Item_Type;
      Next : Stack;
   end record;

   procedure Top (Item : out Item_Type; From : in out Stack) is
   begin
      if Is_Empty(From) then
         raise Underflow;
      else
         Item := From.Item;
      end if;
   end Top;


   procedure Push (Item : in Item_Type; Onto : in out Stack) is
   begin
      Onto := new Cell'(Item => Item, Next => Onto);
   end Push;

   procedure Pop (Item : out Item_Type; From : in out Stack) is
   begin
      if Is_Empty(From) then
         raise Underflow;
      else
         Item := From.Item;
         From := From.Next;
      end if;
   end Pop;



   function Is_Empty (S : Stack) return Boolean is
   begin
      return S = null;
   end Is_Empty;

end Unbound_Stack;
