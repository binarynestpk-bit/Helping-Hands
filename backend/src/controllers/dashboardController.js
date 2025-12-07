const pool = require('../config/database');

exports.getStats = async (req, res) => {
  try {
    const usersCount = await pool.query('SELECT COUNT(*) FROM users');
    const bloodRequestsCount = await pool.query('SELECT COUNT(*) FROM blood_requests');
    const educationRequestsCount = await pool.query('SELECT COUNT(*) FROM education_requests');
    const familyRequestsCount = await pool.query('SELECT COUNT(*) FROM family_requests');

    const pendingUsers = await pool.query("SELECT COUNT(*) FROM users WHERE status = 'pending'");
    const pendingBlood = await pool.query("SELECT COUNT(*) FROM blood_requests WHERE status = 'pending'");
    const pendingEducation = await pool.query("SELECT COUNT(*) FROM education_requests WHERE status = 'pending'");
    const pendingFamily = await pool.query("SELECT COUNT(*) FROM family_requests WHERE status = 'pending'");

    res.json({
      success: true,
      data: {
        totalUsers: parseInt(usersCount.rows[0].count),
        totalBloodRequests: parseInt(bloodRequestsCount.rows[0].count),
        totalEducationRequests: parseInt(educationRequestsCount.rows[0].count),
        totalFamilyRequests: parseInt(familyRequestsCount.rows[0].count),
        pendingUsers: parseInt(pendingUsers.rows[0].count),
        pendingBlood: parseInt(pendingBlood.rows[0].count),
        pendingEducation: parseInt(pendingEducation.rows[0].count),
        pendingFamily: parseInt(pendingFamily.rows[0].count),
      },
    });
  } catch (error) {
    console.error('Get stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.getActivity = async (req, res) => {
  try {
    res.json({
      success: true,
      data: [],
    });
  } catch (error) {
    console.error('Get activity error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.getChartData = async (req, res) => {
  try {
    res.json({
      success: true,
      data: [],
    });
  } catch (error) {
    console.error('Get chart data error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};
