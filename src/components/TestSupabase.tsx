import { useState } from 'react';
import { supabase } from '../lib/supabase';

export default function TestSupabase() {
  const [loading, setLoading] = useState(false);

  const handleTestCall = async () => {
    setLoading(true);
    try {
      // 1. Sign in
      const { data: authData, error: signInError } = await supabase.auth.signInWithPassword({
        email: 'test@gala.com',
        password: 'password123',
      });
      if (signInError) throw signInError;

      // 2. Call the function
      const { data, error } = await supabase.rpc('create_event', {
        event_title: 'End-to-End Integration Test',
        event_desc: 'Testing authentication, RLS, and RPC triggers',
        start_date: new Date().toISOString(),
        end_date: new Date(Date.now() + 3600000).toISOString(),
        location_name: 'Testing Grounds'
      });

      if (error) throw error;
      
      alert(`Success! Event created with ID: ${data}`);
    } catch (err) {
      console.error('Error details:', err);
      alert('Test failed. Check the browser console (F12) for the error message.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <button 
      onClick={handleTestCall}
      disabled={loading}
      className="p-4 bg-green-600 text-white rounded hover:bg-green-700 disabled:bg-gray-400"
    >
      {loading ? 'Testing...' : 'Test Full Auth & RPC Flow'}
    </button>
  );
}