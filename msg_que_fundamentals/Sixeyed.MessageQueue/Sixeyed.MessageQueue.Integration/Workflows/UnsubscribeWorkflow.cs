using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Sixeyed.MessageQueue.Integration.Workflows
{
    public  class UnsubscribeWorkflow
    {
        private const int StepDuration = 10000; 

        public string EmailAddress { get; private set; }

        public UnsubscribeWorkflow(string emailAddress)
        {
            EmailAddress = emailAddress;
        }

        public void Run()
        {
            PersistAsUnsubscribed();
            UnsubscribeInLegacySystem();
            SetCrmMailingPreference();
            CancelPendingMailshots();
        }

        private void CancelPendingMailshots()
        {
            Thread.Sleep(StepDuration);
        }

        private void SetCrmMailingPreference()
        {
            Thread.Sleep(StepDuration);
        }

        private void UnsubscribeInLegacySystem()
        {
            Thread.Sleep(StepDuration);
        }

        private void PersistAsUnsubscribed()
        {
            Thread.Sleep(StepDuration);
        }
    }
}
