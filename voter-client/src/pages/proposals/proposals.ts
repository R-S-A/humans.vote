import { Component, OnInit } from '@angular/core';
import { IonicPage, NavController, NavParams } from 'ionic-angular';
import * as ethers from 'ethers';
import * as keythereum from 'keythereum';
import { WalletUtilsProvider } from '../../providers/wallet-utils/wallet-utils';

const utils = ethers.utils;

@Component({
  selector: 'page-proposals',
  templateUrl: 'proposals.html',
})
export class ProposalsPage implements OnInit {
  wallet;
  provider;
  address;
  balanceCheckAddress;
  balance: string = '0.0';
  etherValue: string = '0.0';
  recipientAddress: string;
  addressBalance: string = '0.0';
  sending: boolean = false;

  constructor(
    private walletUtils: WalletUtilsProvider
  ) {

  }

  async ngOnInit() {

    this.provider = this.walletUtils.provider;
    this.wallet = this.walletUtils.wallet;
    this.address = this.walletUtils.walletAddress;

    this.balance = await this.walletUtils.checkMyWalletBalance();

  }

  /**
   * [TAP] Check balance on selected address
   * @returns {Promise<void>}
   */
  async checkAddressBalanceTap() {

    if (!this.walletUtils.validateAddress(this.balanceCheckAddress)) return alert('Invalid ethereum address');

    try {
      this.addressBalance = await this.walletUtils.checkAddressBalance(this.balanceCheckAddress);
    } catch (err) {
      console.log(err);
      alert('Trouble accessing RPC');
    }

  }

  /**
   * [TAP] Check balance on my wallet
   * @returns {Promise<void>}
   */
  async checkMyBalanceTap() {

    try {
      this.balance = await this.walletUtils.checkMyWalletBalance();
    } catch (err) {
      alert('Trouble accessing RPC');
    }

  }

  /**
   * [TAP] Send ether
   * @returns {Promise<any>}
   */
  async sendEthTap() {

    if (!this.walletUtils.validateAddress(this.recipientAddress)) return alert('Invalid ethereum address');
    try {

      console.log('this.etherValue: ', this.etherValue);
      console.log('this.recipientAddress: ', this.recipientAddress);

      this.sending = true;

      const transactionResult = await this.walletUtils.sendTransaction({
        gasLimit: 1000000,
        gasPrice: utils.bigNumberify('20000000000'),
        to: this.recipientAddress,
        value: utils.parseEther(this.etherValue)
      });

      // Get notified when a transaction is mined
      this.provider.once(transactionResult.hash, (transaction) => {
        this.sending = false;
      });

      return transactionResult;

    } catch (err) {
      console.log(err);
      alert('Trouble accessing RPC: ');
    }

  }

}
