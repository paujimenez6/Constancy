import { createClient } from 'npm:@supabase/supabase-js@2'
import { initializeApp, cert, getApps } from 'npm:firebase-admin@11/app'
import { getMessaging } from 'npm:firebase-admin@11/messaging'

const serviceAccountStr = Deno.env.get('FIREBASE_SERVICE_ACCOUNT');
if (!serviceAccountStr) throw new Error('Secret FIREBASE_SERVICE_ACCOUNT no trobat.');

const serviceAccount = JSON.parse(serviceAccountStr);
if (getApps().length === 0) {
  initializeApp({ credential: cert(serviceAccount) });
}

const translations: Record<string, any> = {
  ca: {
    new_follower_title: 'Nou seguidor!',
    new_follower_body: (name: string) => `${name} ha començat a seguir-te.`,
    league_end_title: 'La lliga ha finalitzat!',
    league_end_body: 'Mira com has quedat i descobreix si has pujat de lliga.',
    end_of_day_title: 'Queda poc per acabar el dia!',
    end_of_day_body: 'Encara ets a temps de completar els teus hàbits!',
    group_habit_completed_title: 'Hàbit completat!',
    group_habit_completed_body: (name: string, habit: string) => `${name} ha completat l'hàbit: ${habit}!`,
    habit_reminder_title: 'Recordatori d\'hàbit',
    habit_reminder_body: (habit: string) => `És l'hora del teu hàbit: ${habit}. No ho deixis passar!`,
    default_title: 'Nova activitat',
    default_body: 'Tens una nova notificació a Constancy.'
  },
  es: {
    new_follower_title: '¡Nuevo seguidor!',
    new_follower_body: (name: string) => `${name} ha empezado a seguirte.`,
    league_end_title: '¡La liga ha finalizado!',
    league_end_body: 'Mira cómo has quedado y descubre si has subido de liga.',
    end_of_day_title: '¡Queda poco para acabar el día!',
    end_of_day_body: '¡Aún estás a tiempo de completar tus hábitos!',
    group_habit_completed_title: '¡Hábito completado!',
    group_habit_completed_body: (name: string, habit: string) => `¡${name} ha completado el hábito: ${habit}!`,
    habit_reminder_title: 'Recordatorio de hábito',
    habit_reminder_body: (habit: string) => `Es la hora de tu hábito: ${habit}. ¡No lo dejes pasar!`,
    default_title: 'Nueva actividad',
    default_body: 'Tienes una nueva notificación en Constancy.'
  },
  en: {
    new_follower_title: 'New follower!',
    new_follower_body: (name: string) => `${name} started following you.`,
    league_end_title: 'League finished!',
    league_end_body: 'Check your results and see if you moved up a league.',
    end_of_day_title: 'Almost the end of the day!',
    end_of_day_body: 'Still time to complete your habits!',
    group_habit_completed_title: 'Habit completed!',
    group_habit_completed_body: (name: string, habit: string) => `${name} has completed the habit: ${habit}!`,
    habit_reminder_title: 'Habit reminder',
    habit_reminder_body: (habit: string) => `It's time for your habit: ${habit}. Don't miss it!`,
    default_title: 'New activity',
    default_body: 'You have a new notification on Constancy.'
  }
};

Deno.serve(async (req) => {
  try {
    const payload = await req.json();
    const record = payload.record;

    if (!record || !record.receiver_id) {
      return new Response("Manca informació del receptor", { status: 400 });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const { data: receiver } = await supabase
      .from('profiles')
      .select('fcm_token, locale')
      .eq('id', record.receiver_id)
      .single();

    if (!receiver || !receiver.fcm_token) return new Response("No FCM token", { status: 200 });

    const userLocale = receiver.locale || 'ca';
    const t = translations[userLocale] || translations['ca'];

    let title = t.default_title;
    let body = t.default_body;

    // Lògica segons el tipus de notificació
    if (record.type === 'new_follower' && record.sender_id) {
      const { data: sender } = await supabase.from('profiles').select('nickname').eq('id', record.sender_id).single();
      title = t.new_follower_title;
      body = t.new_follower_body(sender?.nickname || 'Algú');
    } else if (record.type === 'league_end') {
      title = t.league_end_title;
      body = t.league_end_body;
    } else if (record.type === 'end_of_day') {
      title = t.end_of_day_title;
      body = t.end_of_day_body;
    } else if (record.type === 'group_habit_completed' && record.sender_id && record.habit_id) {
      const { data: sender } = await supabase.from('profiles').select('nickname').eq('id', record.sender_id).single();
      const { data: habit } = await supabase.from('habits').select('titol').eq('id', record.habit_id).single();
      title = t.group_habit_completed_title;
      body = t.group_habit_completed_body(sender?.nickname || 'Algú', habit?.titol || 'Hàbit');
    } else if (record.type === 'habit_reminder' && record.habit_id) {
      const { data: habit } = await supabase.from('habits').select('titol').eq('id', record.habit_id).single();
      title = t.habit_reminder_title;
      body = t.habit_reminder_body(habit?.titol || 'Hàbit');
    }

    const message = {
      token: receiver.fcm_token,
      notification: { title, body },
      data: {
        type: record.type,
        habit_id: record.habit_id || ''
      }
    };

    await getMessaging().send(message);
    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (error: any) {
    console.error('Error enviant Push:', error);
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});