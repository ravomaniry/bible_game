const path = require('path')
const sequelize = require('sequelize')

const config = {
    dialect: 'sqlite',
    logging: true,
    storage: path.join(__dirname, 'bible_game.db')
}

const db = new sequelize('bible_game', '', '', config)

module.exports = {
    db,
};
