import { supabase } from './supabase';

/**
 * GALA API Layer
 * Maps frontend calls to database RPC functions.
 */
export const api = {
  events: {
    create: async (title: string, desc: string, startDate: string, location: string) => {
      const { data, error } = await supabase.rpc('create_event', {
        event_title: title,
        event_desc: desc,
        start_date: startDate,
        location_name: location
      });
      if (error) throw error;
      return data;
    }
  },
  invitations: {
    accept: async (inviteId: number) => {
      const { error } = await supabase.rpc('accept_event_invitation', {
        invite_id: inviteId
      });
      if (error) throw error;
    }
  },
  friends: {
    add: async (id1: number, id2: number) => {
      const { error } = await supabase.rpc('insert_friendship', {
        id1: id1,
        id2: id2
      });
      if (error) throw error;
    }
  }
};