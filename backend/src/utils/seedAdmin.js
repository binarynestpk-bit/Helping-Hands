const bcrypt = require('bcryptjs');
const pool = require('../config/database');
require('dotenv').config();

async function seedAdmin() {
  try {
    console.log('🌱 Seeding admin user...');

    const email = process.env.ADMIN_EMAIL || 'admin@helpinghand.com';
    const password = process.env.ADMIN_PASSWORD || 'Admin@123';

    const existingAdmin = await pool.query(
      'SELECT * FROM admins WHERE email = $1',
      [email]
    );

    if (existingAdmin.rows.length > 0) {
      console.log('⚠️  Admin user already exists!');
      console.log(`📧 Email: ${email}`);
      console.log(`🔑 Password: Use your existing password or update in .env`);
      process.exit(0);
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    await pool.query(
      `INSERT INTO admins (email, password_hash, name, role, is_active, created_at)
       VALUES ($1, $2, $3, $4, $5, CURRENT_TIMESTAMP)`,
      [email, hashedPassword, 'Super Admin', 'super_admin', true]
    );

    console.log('✅ Admin user created successfully!');
    console.log('');
    console.log('📧 Email:', email);
    console.log('🔑 Password:', password);
    console.log('');
    console.log('🔗 Login at: http://localhost:3001/login');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding admin:', error);
    process.exit(1);
  }
}

seedAdmin();
