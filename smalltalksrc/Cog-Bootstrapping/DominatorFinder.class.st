"
A DominatorFinder is an InstructionStream that finds the dominators of bytecodes.  Specifically it aims to find the dominating conditional branches for join points.  This is part of the register allocation problem, to know the common height of the stack at a join point.  Only items above the common height need to be merged.

I believe finding dominators in bytecode can be done with a simple scan using an FSM, e.g. in scanMethod.  This class is part of an experiment to find out if I'm right.

I observe that
- the first conditional branch that branches to a target that is preceded by an unconditional branch dominates the target of the unconditional branch
- if no conditional branch that branches to a target, branches to a target preceded by an unconditional branch (i.e. all are preceded by returns) then the first conditional branch dominates the target
- a conditional branch that branches to a target preceded by a backward branch dominates its target (loops)

Instance Variables
	cameFroms:			<Array>
	dominators:			<Dictionary>
	encoderClass:			<BytecodeEncoder>
	previousInstruction:	<Symbol>
	thisInstruction:			<Symbol>
	thisPC:					<Integer>

cameFroms
	- the pcs of dominating conditional branches

dominators
	- dictionary of dominating pc to dominated pc

encoderClass
	- the encoderClass for the current method

previousInstruction
	- the selector of the Message for the previous bytecode during the scan

thisInstruction
	- the selector of the Message for the current bytecode during the scan

thisPC
	- the pc for the current bytecode during the scan

"
Class {
	#name : #DominatorFinder,
	#superclass : #InstructionStream,
	#instVars : [
		'cameFroms',
		'dominators',
		'encoderClass',
		'thisInstruction',
		'previousInstruction',
		'jumpTarget',
		'thisPC',
		'targets'
	],
	#classVars : [
		'ReturnSelectors'
	],
	#category : #'Cog-Explorations'
}

{ #category : #'class initialization' }
DominatorFinder class >> initialize [
	"self initialize"
	ReturnSelectors := ((self systemNavigation allCallsOn: #return:from: localTo: Context) collect: [:mr| mr selector]) as: IdentitySet.
]

{ #category : #'message handling' }
DominatorFinder >> doesNotUnderstand: aMessage [
	self recordThisInstruction: aMessage
]

{ #category : #accessing }
DominatorFinder >> dominators [
	"Scan to find the dominating conditional branches."
	| end |
	end := self method endPC.
	[pc <= end] whileTrue:
		[self interpretNextInstructionFor: self].
	^dominators
]

{ #category : #decoding }
DominatorFinder >> interpretNextInstructionFor: client [
	| result |
	(cameFroms at: pc) ifNotNil:
		[:cameFromPC|
		"the first conditional branch that branches to a target that is preceded by an unconditional branch dominates the target of the unconditional branch"
		previousInstruction == #jump:
			ifTrue:
		 		[(jumpTarget >= pc
				  and: [(targets includes: jumpTarget) not]) ifTrue:
					[dominators at: cameFromPC put: jumpTarget.
					 targets add: jumpTarget]]
			ifFalse:
				[(targets includes: pc) ifFalse:
					[dominators at: cameFromPC put: pc.
					 targets add: pc]]].
	thisPC := pc.
	result := encoderClass interpretNextInstructionFor: client in: self.
	previousInstruction := thisInstruction
]

{ #category : #private }
DominatorFinder >> isReturn: aMessageSelector [
	^ReturnSelectors includes: aMessageSelector
]

{ #category : #'instruction decoding' }
DominatorFinder >> jump: distance [
	jumpTarget := pc + distance.
	self recordThisInstruction: (Message selector: #jump: argument: distance)
]

{ #category : #'instruction decoding' }
DominatorFinder >> jump: distance if: condition [
	| target |
	target := pc + distance.
	(cameFroms at: target)
		ifNil: [cameFroms at: target put: thisPC]
		ifNotNil: [:cameFromPC| self assert: cameFromPC < thisPC].
	self recordThisInstruction: (Message selector: #jump: argument: distance)
]

{ #category : #private }
DominatorFinder >> method: method pc: startpc [
	super method: method pc: startpc.
	cameFroms := Array new: method endPC.
	encoderClass := method encoderClass.
	dominators := Dictionary new.
	targets := Set new
]

{ #category : #private }
DominatorFinder >> recordThisInstruction: aMessage [
	thisInstruction := aMessage selector
]