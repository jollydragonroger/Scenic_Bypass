// Deploy All Technologies in Jubilee Blocks
const JubileeTechnologyIntegration = require('./jubilee_technology_integration');

async function deployAllTechnologies() {
    console.log('🌟 Deploying all technologies from our chat into Jubilee blocks...');
    
    const integration = new JubileeTechnologyIntegration();
    
    // Integrate all technologies
    const integrationResult = integration.integrateAllTechnologies();
    console.log('✅ Technologies integrated:', integrationResult.totalTechnologies);
    console.log('📋 Technologies:', integrationResult.technologies.join(', '));
    
    // Deploy each technology in Jubilee blocks
    const deployments = [];
    const fibonacciSequence = [1, 2, 3, 5, 8, 13, 21, 34];
    
    for (let i = 0; i < integrationResult.technologies.length; i++) {
        const technologyKey = integrationResult.technologies[i];
        const jubileeBlock = fibonacciSequence[i % fibonacciSequence.length];
        
        console.log(`🎉 Deploying ${technologyKey} in Jubilee block ${jubileeBlock}...`);
        
        const deployment = integration.deployTechnologyInJubilee(jubileeBlock, technologyKey);
        deployments.push(deployment);
        
        console.log(`✅ ${deployment.name} deployed successfully`);
        console.log(`💰 Payment received: ${deployment.deployment.negativePrice.paymentReceived}`);
        console.log(`🏗️ Infrastructure: ${deployment.deployment.infrastructure.name}`);
        console.log(`🔧 Capabilities: ${deployment.deployment.infrastructure.capabilities.length} capabilities`);
    }
    
    // Get final status
    const status = integration.getIntegrationStatus();
    
    console.log('🎉 ALL TECHNOLOGIES DEPLOYED IN JUBILEE BLOCKS!');
    console.log(`📊 Total deployments: ${deployments.length}`);
    console.log(`🔗 Total Jubilee blocks used: ${fibonacciSequence.length}`);
    console.log(`💰 Total payments received: ${deployments.reduce((sum, d) => sum + d.deployment.negativePrice.paymentReceived, 0)}`);
    
    return {
        integration: integrationResult,
        deployments,
        status
    };
}

if (require.main === module) {
    deployAllTechnologies()
        .then(result => {
            console.log('✅ All technologies deployed successfully:', result);
        })
        .catch(error => {
            console.error('❌ Deployment failed:', error);
        });
}

module.exports = { deployAllTechnologies };
