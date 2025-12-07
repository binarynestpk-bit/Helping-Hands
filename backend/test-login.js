const bcrypt = require('bcryptjs');
const pool = require('./src/config/database');

async function testLogin() {
  try {
    const email = 'admin@helpinghand.com';
    const password = 'Admin@123';

    console.log('Testing login for:', email);
    console.log('Password:', password);
    console.log('');

    const result = await pool.query(
      'SELECT * FROM admins WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      console.log('❌ Admin not found in database');
      process.exit(1);
    }

    const admin = result.rows[0];
    console.log('✅ Admin found:', admin.name);
    console.log('Email:', admin.email);
    console.log('Role:', admin.role);
    console.log('Active:', admin.is_active);
    console.log('');

    const isPasswordValid = await bcrypt.compare(password, admin.password_hash);

    if (isPasswordValid) {
      console.log('✅ Password is CORRECT!');
      console.log('');
      console.log('Login credentials:');
      console.log('📧 Email: admin@helpinghand.com');
      console.log('🔑 Password: Admin@123');
    } else {
      console.log('❌ Password is INCORRECT!');
      console.log('');
      console.log('Recreating admin with correct password...');

      const hashedPassword = await bcrypt.hash(password, 10);
      await pool.query(
        'UPDATE admins SET password_hash = $1 WHERE email = $2',
        [hashedPassword, email]
      );

      console.log('✅ Password updated successfully!');
      console.log('');
      console.log('Login credentials:');
      console.log('📧 Email: admin@helpinghand.com');
      console.log('🔑 Password: Admin@123');
    }

    await pool.end();
    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

testLogin();
