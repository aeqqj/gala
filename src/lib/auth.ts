import { supabase } from './supabase';

export const auth = {
  // Sign up and trigger verification email
  signUp: async (email: string, password: string, extraData: any) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: extraData } // Stores username, first_name, etc.
    });
    if (error) throw error;
    return data;
  },

  // Login
  signIn: async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });
    if (error) throw error;
    return data;
  },

  // Sign out
  signOut: async () => {
    await supabase.auth.signOut();
  }
};