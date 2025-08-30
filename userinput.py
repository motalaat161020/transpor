#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
User Input Script for Interactive Loop
This script collects the next user instruction to continue the interactive session.
يدعم اللغة العربية والإنجليزية
"""

def get_user_input():
    """Get the next user instruction."""
    print("\n" + "="*60)
    print("✅ تم إنجاز المهمة! ماذا تريد مني أن أفعل بعد ذلك؟")
    print("✅ Task completed! What would you like me to do next?")
    print("="*60)
    print("💡 يمكنك الكتابة بالعربية أو الإنجليزية")
    print("💡 You can type in Arabic or English")
    print("="*60)
    print("❌ اكتب 'exit' للخروج")
    print("❌ Type 'exit' to end the session")
    print("="*60)
    
    try:
        user_input = input("🔹 رسالتك / Your message: ").strip()
        return user_input
    except KeyboardInterrupt:
        print("\n\n⏹️ تم إيقاف الجلسة. خروج...")
        print("⏹️ Session interrupted. Exiting...")
        return "exit"
    except EOFError:
        print("\n\n🔚 نهاية المدخلات. خروج...")
        print("🔚 End of input. Exiting...")
        return "exit"

if __name__ == "__main__":
    user_input = get_user_input()
    print(f"\n📝 الرسالة التالية: {user_input}")
    print(f"📝 Next instruction: {user_input}")
    
    # Exit if user types 'exit'
    if user_input.lower() == "exit":
        print("👋 تم إنهاء الجلسة كما طلبت.")
        print("👋 Ending session as requested.")
        exit(0)
