-----------------------------------------------------------------------
--  EL.Contexts -- Default contexts for evaluating an expression
--  Copyright (C) 2009, 2010 Stephane Carrez
--  Written by Stephane Carrez (Stephane.Carrez@gmail.com)
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
-----------------------------------------------------------------------

package EL.Contexts.Default is

   --  ------------------------------
   --  Default Context
   --  ------------------------------
   --  Context information for expression evaluation.
   type Default_Context is new ELContext with private;

   --  Retrieves the ELResolver associated with this ELcontext.
   overriding
   function Get_Resolver (Context : Default_Context) return ELResolver_Access;

   --  Retrieves the VariableMapper associated with this ELContext.
   overriding
   function Get_Variable_Mapper (Context : Default_Context)
                                 return access EL.Variables.VariableMapper'Class;

   --  Retrieves the FunctionMapper associated with this ELContext.
   --  The FunctionMapper is only used when parsing an expression.
   overriding
   function Get_Function_Mapper (Context : Default_Context)
                                 return EL.Functions.Function_Mapper_Access;

   procedure Set_Variable (Context : in out Default_Context;
                           Name    : in String;
                           Value   : access EL.Beans.Readonly_Bean'Class);

   --  ------------------------------
   --  Default Resolver
   --  ------------------------------
   type Default_ELResolver is new ELResolver with private;

   --  Get the value associated with a base object and a given property.
   overriding
   function Get_Value (Resolver : Default_ELResolver;
                       Context  : ELContext'Class;
                       Base     : access EL.Beans.Readonly_Bean'Class;
                       Name     : Unbounded_String) return Object;

   --  Set the value associated with a base object and a given property.
   overriding
   procedure Set_Value (Resolver : in Default_ELResolver;
                        Context  : in ELContext'Class;
                        Base     : access EL.Beans.Bean'Class;
                        Name     : in Unbounded_String;
                        Value    : in Object);

private

   type Default_Context is new ELContext with record
      Var_Mapper : access EL.Variables.VariableMapper'Class;
      Resolver   : ELResolver_Access;
      Function_Mapper : EL.Functions.Function_Mapper_Access;
   end record;

   use EL.Beans;

   type Default_ELResolver is new ELResolver with record
      N : Natural;
   end record;

end EL.Contexts.Default;
