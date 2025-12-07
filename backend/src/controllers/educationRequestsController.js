const pool = require('../config/database');

exports.getAllEducationRequests = async (req, res) => {
  try {
    const { status } = req.query;

    let query = `
      SELECT er.*, u.full_name as user_name, u.email as user_email
      FROM education_requests er
      LEFT JOIN users u ON er.user_id = u.id
      ORDER BY er.created_at DESC
    `;
    let params = [];

    if (status) {
      query = `
        SELECT er.*, u.full_name as user_name, u.email as user_email
        FROM education_requests er
        LEFT JOIN users u ON er.user_id = u.id
        WHERE er.status = $1
        ORDER BY er.created_at DESC
      `;
      params = [status];
    }

    const result = await pool.query(query, params);

    res.json({
      success: true,
      data: result.rows,
    });
  } catch (error) {
    console.error('Get education requests error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.getEducationRequestById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `SELECT er.*, u.full_name as user_name, u.email as user_email
       FROM education_requests er
       LEFT JOIN users u ON er.user_id = u.id
       WHERE er.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Education request not found',
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Get education request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.approveEducationRequest = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `UPDATE education_requests
       SET status = 'approved',
           admin_approved_by = $1,
           approved_at = CURRENT_TIMESTAMP,
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $2
       RETURNING *`,
      [req.admin.id, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Education request not found',
      });
    }

    res.json({
      success: true,
      message: 'Education request approved successfully',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Approve education request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

exports.rejectEducationRequest = async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const result = await pool.query(
      `UPDATE education_requests
       SET status = 'rejected',
           updated_at = CURRENT_TIMESTAMP
       WHERE id = $2
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Education request not found',
      });
    }

    res.json({
      success: true,
      message: 'Education request rejected successfully',
      data: result.rows[0],
    });
  } catch (error) {
    console.error('Reject education request error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};
