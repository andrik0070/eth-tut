/**
 * Created by andrew on 18.10.2.
 */


const contract = require("truffle-contract");
var Exchange = require('../../build/contracts/Exchange.json');
Exchange = contract(Exchange);

export {Exchange};
