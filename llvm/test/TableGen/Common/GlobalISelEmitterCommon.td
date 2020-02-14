// Common target boilerplate for GlobalISelEmitter tests.
def MyTargetISA : InstrInfo;
def MyTarget : Target { let InstructionSet = MyTargetISA; }

class MyTargetGenericInstruction : GenericInstruction {
  let Namespace = "MyTarget";
}

def R0 : Register<"r0"> { let Namespace = "MyTarget"; }
def Q0 : Register<"q0"> { let Namespace = "MyTarget"; }
def GPR32 : RegisterClass<"MyTarget", [i32, v2i16], 32, (add R0)>;
def GPR64 : RegisterClass<"MyTarget", [i64, f64], 64, (add Q0)>;
def GPR32Op : RegisterOperand<GPR32>;
def F0 : Register<"f0"> { let Namespace = "MyTarget"; }
def FPR32 : RegisterClass<"MyTarget", [f32], 32, (add F0)>;
def FPR32Op : RegisterOperand<FPR32>;
def p0 : PtrValueType <i32, 0>;

class I<dag OOps, dag IOps, list<dag> Pat>
  : Instruction {
  let Namespace = "MyTarget";
  let OutOperandList = OOps;
  let InOperandList = IOps;
  let Pattern = Pat;
}
