package de.oehme.xtend.annotation.data

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtext.xbase.lib.Procedures

@Active(typeof(ImmutableProcessor))
annotation Immutable {
}

class ImmutableProcessor extends AbstractClassProcessor {

	override doRegisterGlobals(ClassDeclaration cls, RegisterGlobalsContext context) {
		context.registerClass(cls.builderClassName)
	}

	override doTransform(MutableClassDeclaration cls, extension TransformationContext context) {
		if(cls.extendedClass != object) cls.addError("Inheritance does not play well with immutability")
		cls.final = true

		val builder = cls.builderClass(context)=> [
			final = true
			addMethod("build") [
				returnType = cls.newTypeReference
				body = [
					'''
						return new «cls.simpleName»(«cls.dataFields.join(",")[simpleName]»);
					''']
			]
			cls.dataFields.forEach [ field |
				addMethod(field.simpleName) [
					addParameter(field.simpleName, field.type)
					returnType = cls.builderClass(context).newTypeReference
					body = [
						'''
							this.«field.simpleName» = «field.simpleName»;
							return this;
						''']
				]
				addField(field.simpleName) [
					type = field.type
				]
			]
		]

		cls.addMethod("build") [
			static = true
			returnType = cls.newTypeReference
			addParameter("init", typeof(Procedures$Procedure1).newTypeReference(builder.newTypeReference))
			body = [
				'''
					«cls.builderClassName» builder = builder();
					init.apply(builder);
					return builder.build();
				''']
		]
		cls.addMethod("builder") [
			returnType = cls.builderClass(context).newTypeReference
			static = true
			body = [
				'''
					return new «cls.builderClassName»();
				''']
		]

		cls.addConstructor [
			cls.dataFields.forEach [ field |
				addParameter(field.simpleName, field.type)
			]
			body = [
				'''
					«FOR p : cls.dataFields»
						this.«p.simpleName» = «p.simpleName»;
					«ENDFOR»
				''']
		]
		cls.dataFields.forEach [ field |
			cls.addMethod("get" + field.simpleName.toFirstUpper) [
				returnType = field.type
				body = [
					'''
						return «field.simpleName»;
					''']
			]
			//TODO https://bugs.eclipse.org/bugs/show_bug.cgi?id=404167
			cls.addField(field.simpleName) [
				type = field.type
				initializer = field.initializer
			]
			field.remove
		]
		cls.addMethod("equals") [
			returnType = primitiveBoolean
			addParameter("o", object)
			body = [
				'''
					if (o instanceof «cls.simpleName») {
						«cls.simpleName» other = («cls.simpleName») o;
						return «cls.dataFields.join("\n&& ")['''«objects».equal(«simpleName», other.«simpleName»)''']»;
					}
					return false;
				''']
		]
		cls.addMethod("hashCode") [
			returnType = primitiveInt
			body = ['''return «objects».hashCode(«cls.dataFields.join(",")[simpleName]»);''']
		]
		cls.addMethod("toString") [
			returnType = string
			body = ['''return "«cls.simpleName»{"+«cls.dataFields.join('+", "+')[simpleName]»+"}";''']
		]
	}

	def dataFields(MutableClassDeclaration cls) {
		cls.declaredFields.filter[static == false]
	}

	def builderClassName(ClassDeclaration cls) {
		cls.qualifiedName + "Builder"
	}

	def objects() {
		"com.google.common.base.Objects"
	}

	def builderClass(ClassDeclaration cls, extension TransformationContext ctx) {
		cls.builderClassName.findClass
	}
}
